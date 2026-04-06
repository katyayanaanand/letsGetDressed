package com.letsgetdressed.service;

import com.letsgetdressed.model.WardrobeItem;
import com.letsgetdressed.repository.WardrobeItemRepository;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class WardrobeService {

    private static final Logger logger = LoggerFactory.getLogger(WardrobeService.class);

    private final WardrobeItemRepository wardrobeItemRepository;
    private final PineconeService pineconeService;
    private final EmbeddingService embeddingService;

    public WardrobeService(
            WardrobeItemRepository wardrobeItemRepository,
            PineconeService pineconeService,
            EmbeddingService embeddingService) {
        this.wardrobeItemRepository = wardrobeItemRepository;
        this.pineconeService = pineconeService;
        this.embeddingService = embeddingService;
    }

    /**
     * Get all active (non-archived) wardrobe items.
     */
    public List<WardrobeItem> getAllItems() {
        return wardrobeItemRepository.findByArchivedFalseOrderByCreatedAtDesc();
    }

    /**
     * Get a specific wardrobe item by ID.
     */
    public WardrobeItem getItemById(String id) {
        Optional<WardrobeItem> item = wardrobeItemRepository.findById(id);
        return item.filter(w -> !w.getArchived()).orElse(null);
    }

    /**
     * Add a new wardrobe item and generate embeddings.
     */
    @Transactional
    public WardrobeItem addItem(WardrobeItem item) {
        // Save to database
        WardrobeItem savedItem = wardrobeItemRepository.save(item);

        // Generate embedding and store in vector DB
        try {
            String metadata = embeddingService.generateMetadataString(
                    item.getName(),
                    item.getCategory(),
                    item.getColor(),
                    item.getSeason(),
                    item.getOccasion());

            List<Float> embedding = embeddingService.generateEmbedding(metadata);

            Map<String, String> pineconeMetadata = new HashMap<>();
            pineconeMetadata.put("itemId", savedItem.getId());
            pineconeMetadata.put("name", item.getName());
            pineconeMetadata.put("category", item.getCategory());
            pineconeMetadata.put("color", item.getColor() != null ? item.getColor() : "");
            pineconeMetadata.put("season", item.getSeason() != null ? item.getSeason() : "");
            pineconeMetadata.put("occasion", item.getOccasion() != null ? item.getOccasion() : "");

            pineconeService.upsertVector(savedItem.getId(), embedding, pineconeMetadata);

            logger.info("Successfully added wardrobe item: {}", savedItem.getId());
        } catch (Exception e) {
            logger.error("Error generating embedding for item: {}", item.getName(), e);
            // Don't fail the item creation if embedding fails
        }

        return savedItem;
    }

    /**
     * Archive a wardrobe item (soft delete).
     */
    @Transactional
    public WardrobeItem archiveItem(String id) {
        Optional<WardrobeItem> item = wardrobeItemRepository.findById(id);
        if (item.isPresent()) {
            WardrobeItem wardrobeItem = item.get();
            wardrobeItem.setArchived(true);
            WardrobeItem archived = wardrobeItemRepository.save(wardrobeItem);

            // Remove from vector DB
            pineconeService.deleteVector(id);

            logger.info("Archived wardrobe item: {}", id);
            return archived;
        }
        return null;
    }

    /**
     * Get items by category.
     */
    public List<WardrobeItem> getItemsByCategory(String category) {
        return wardrobeItemRepository.findByCategory(category);
    }

    /**
     * Get items by season.
     */
    public List<WardrobeItem> getItemsBySeason(String season) {
        return wardrobeItemRepository.findBySeason(season);
    }

    /**
     * Get items by occasion.
     */
    public List<WardrobeItem> getItemsByOccasion(String occasion) {
        return wardrobeItemRepository.findByOccasion(occasion);
    }

    /**
     * Get items by color (contains match).
     */
    public List<WardrobeItem> getItemsByColor(String color) {
        return wardrobeItemRepository.findByColorContaining(color);
    }
}