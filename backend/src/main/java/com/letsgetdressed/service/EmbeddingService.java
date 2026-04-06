package com.letsgetdressed.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.ArrayList;
import java.util.List;
import org.apache.hc.client5.http.classic.HttpClient;
import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.ContentType;
import org.apache.hc.core5.http.io.entity.StringEntity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * Service to generate image embeddings using OpenAI's embedding API.
 * Embeddings are vector representations of images for similarity matching.
 */
@Service
public class EmbeddingService {

    private static final Logger logger = LoggerFactory.getLogger(EmbeddingService.class);
    private static final String OPENAI_EMBEDDING_URL = "https://api.openai.com/v1/embeddings";

    @Value("${openai.api-key}")
    private String openAiApiKey;

    @Value("${openai.model}")
    private String embeddingModel;

    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Generate embeddings for wardrobe item metadata.
     * This creates a searchable vector representation based on item attributes.
     */
    public List<Float> generateEmbedding(String itemMetadata) {
        try {
            return callOpenAiEmbeddingApi(itemMetadata);
        } catch (Exception e) {
            logger.error("Error generating embedding for metadata: {}", itemMetadata, e);
            return generatePlaceholderEmbedding();
        }
    }

    /**
     * Generate metadata string from wardrobe item attributes for embedding.
     */
    public String generateMetadataString(
            String name, String category, String color, String season, String occasion) {
        return String.format(
                "A %s %s clothing item that is %s in color, suitable for %s occasions during %s.",
                season, category, color, occasion, season);
    }

    private List<Float> callOpenAiEmbeddingApi(String text) throws Exception {
        HttpClient httpClient = HttpClients.createDefault();
        HttpPost httpPost = new HttpPost(OPENAI_EMBEDDING_URL);

        // Set headers
        httpPost.setHeader("Authorization", "Bearer " + openAiApiKey);
        httpPost.setHeader("Content-Type", "application/json");

        // Build request body
        String requestBody = String.format(
                "{\"input\": \"%s\", \"model\": \"%s\"}",
                text.replace("\"", "\\\""), embeddingModel);

        httpPost.setEntity(new StringEntity(requestBody, ContentType.APPLICATION_JSON));

        // Execute request
        return httpClient.execute(httpPost, response -> {
            String responseBody = new String(response.getEntity().getContent().readAllBytes());
            JsonNode root = objectMapper.readTree(responseBody);

            List<Float> embedding = new ArrayList<>();
            JsonNode dataArray = root.get("data");
            if (dataArray != null && dataArray.isArray() && dataArray.size() > 0) {
                JsonNode embeddingArray = dataArray.get(0).get("embedding");
                if (embeddingArray != null && embeddingArray.isArray()) {
                    for (JsonNode value : embeddingArray) {
                        embedding.add(value.floatValue());
                    }
                }
            }

            return embedding;
        });
    }

    /**
     * Placeholder embedding for development/testing without OpenAI API.
     * In production, always use real embeddings.
     */
    private List<Float> generatePlaceholderEmbedding() {
        List<Float> embedding = new ArrayList<>();
        for (int i = 0; i < 1536; i++) {
            embedding.add((float) Math.random() * 2 - 1);
        }
        return embedding;
    }
}
