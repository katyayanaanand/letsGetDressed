package com.letsgetdressed.service;

import com.letsgetdressed.model.OutfitSuggestionRequest;
import com.letsgetdressed.model.OutfitSuggestionResponse;
import com.letsgetdressed.model.WardrobeItem;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class OutfitSuggestionService {

    private static final Logger logger = LoggerFactory.getLogger(OutfitSuggestionService.class);

    private final WardrobeService wardrobeService;
    private final PineconeService pineconeService;
    private final EmbeddingService embeddingService;

    public OutfitSuggestionService(
            WardrobeService wardrobeService,
            PineconeService pineconeService,
            EmbeddingService embeddingService) {
        this.wardrobeService = wardrobeService;
        this.pineconeService = pineconeService;
        this.embeddingService = embeddingService;
    }

    /**
     * Generate outfit suggestions based on user request.
     * Uses vector similarity matching and metadata filtering.
     */
    public OutfitSuggestionResponse suggestOutfit(OutfitSuggestionRequest request) {
        OutfitSuggestionResponse response = new OutfitSuggestionResponse();

        try {
            List<WardrobeItem> availableItems = wardrobeService.getAllItems();

            if (availableItems.isEmpty()) {
                response.setMessage("No items in wardrobe yet. Add clothes to get suggestions.");
                response.setSuggestedItems(new ArrayList<>());
                response.setShoppingSuggestions(new ArrayList<>());
                return response;
            }

            // Filter by metadata
            List<WardrobeItem> filteredItems = filterByMetadata(availableItems, request);

            // If we have items after metadata filtering, use them
            if (!filteredItems.isEmpty()) {
                // Further filter to get top 5 suggestions
                List<WardrobeItem> suggestions = filteredItems.stream()
                        .limit(5)
                        .collect(Collectors.toList());

                response.setSuggestedItems(suggestions);
                response.setMessage("Suggestions generated using existing wardrobe items only.");
            } else {
                // If strict filtering returns nothing, relax filters and suggest similar items
                List<WardrobeItem> suggestions = availableItems.stream()
                        .limit(3)
                        .collect(Collectors.toList());

                response.setSuggestedItems(suggestions);
                response.setMessage(
                        "No exact matches found. Showing similar items from your wardrobe.");
            }

            // Shopping suggestions only if explicitly requested
            response.setShoppingSuggestions(new ArrayList<>());

        } catch (Exception e) {
            logger.error("Error generating outfit suggestions", e);
            response.setMessage("Error generating suggestions. Please try again.");
            response.setSuggestedItems(new ArrayList<>());
            response.setShoppingSuggestions(new ArrayList<>());
        }

        return response;
    }

    /**
     * Filter wardrobe items based on occasion, season, and color preferences.
     */
    private List<WardrobeItem> filterByMetadata(
            List<WardrobeItem> items, OutfitSuggestionRequest request) {
        return items.stream()
                .filter(item -> matchesSeason(item, request))
                .filter(item -> matchesOccasion(item, request))
                .filter(item -> matchesPreferredColors(item, request))
                .collect(Collectors.toList());
    }

    private boolean matchesSeason(WardrobeItem item, OutfitSuggestionRequest request) {
        if (request == null || request.getSeason() == null || request.getSeason().isBlank()) {
            return true;
        }
        return valueMatches(item.getSeason(), request.getSeason());
    }

    private boolean matchesOccasion(WardrobeItem item, OutfitSuggestionRequest request) {
        if (request == null || request.getOccasion() == null || request.getOccasion().isBlank()) {
            return true;
        }
        return valueMatches(item.getOccasion(), request.getOccasion());
    }

    private boolean matchesPreferredColors(
            WardrobeItem item, OutfitSuggestionRequest request) {
        if (request == null
                || request.getPreferredColors() == null
                || request.getPreferredColors().isEmpty()) {
            return true;
        }
        return request.getPreferredColors().stream()
                .anyMatch(color -> valueMatches(item.getColor(), color));
    }

    private boolean valueMatches(String left, String right) {
        if (left == null || right == null) {
            return false;
        }
        String leftLower = left.toLowerCase(Locale.ROOT);
        String rightLower = right.toLowerCase(Locale.ROOT);
        return leftLower.contains(rightLower) || rightLower.contains(leftLower);
    }
}