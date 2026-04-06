package com.letsgetdressed.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
 * Service to interact with Pinecone vector database.
 * Stores and queries vector embeddings for similarity search.
 */
@Service
public class PineconeService {

    private static final Logger logger = LoggerFactory.getLogger(PineconeService.class);

    @Value("${pinecone.api-key}")
    private String pineconeApiKey;

    @Value("${pinecone.index-name}")
    private String indexName;

    @Value("${pinecone.environment}")
    private String environment;

    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Store a wardrobe item's embedding in Pinecone.
     */
    public void upsertVector(String itemId, List<Float> embedding, Map<String, String> metadata) {
        try {
            String endpoint =
                    String.format(
                            "https://%s-%s.pinecone.io/vectors/upsert",
                            indexName, environment);

            Map<String, Object> request = new HashMap<>();
            request.put("namespace", "wardrobe");

            Map<String, Object> vector = new HashMap<>();
            vector.put("id", itemId);
            vector.put("values", embedding);
            vector.put("metadata", metadata);

            request.put("vectors", List.of(vector));

            String jsonPayload = objectMapper.writeValueAsString(request);

            HttpClient httpClient = HttpClients.createDefault();
            HttpPost httpPost = new HttpPost(endpoint);
            httpPost.setHeader("Api-Key", pineconeApiKey);
            httpPost.setHeader("Content-Type", "application/json");
            httpPost.setEntity(new StringEntity(jsonPayload, ContentType.APPLICATION_JSON));

            httpClient.execute(httpPost, response -> {
                logger.info("Upserted vector for item {} with status: {}", itemId, response.getCode());
                return null;
            });
        } catch (Exception e) {
            logger.error("Error upserting vector to Pinecone for item: {}", itemId, e);
        }
    }

    /**
     * Query Pinecone for similar items based on embedding.
     */
    public List<Map<String, Object>> querySimilarItems(List<Float> queryEmbedding, int topK) {
        try {
            String endpoint =
                    String.format(
                            "https://%s-%s.pinecone.io/query",
                            indexName, environment);

            Map<String, Object> request = new HashMap<>();
            request.put("namespace", "wardrobe");
            request.put("vector", queryEmbedding);
            request.put("topK", topK);
            request.put("includeMetadata", true);

            String jsonPayload = objectMapper.writeValueAsString(request);

            HttpClient httpClient = HttpClients.createDefault();
            HttpPost httpPost = new HttpPost(endpoint);
            httpPost.setHeader("Api-Key", pineconeApiKey);
            httpPost.setHeader("Content-Type", "application/json");
            httpPost.setEntity(new StringEntity(jsonPayload, ContentType.APPLICATION_JSON));

            return httpClient.execute(httpPost, response -> {
                String responseBody = new String(response.getEntity().getContent().readAllBytes());
                Map<String, Object> result = objectMapper.readValue(responseBody, Map.class);
                return (List<Map<String, Object>>) result.get("matches");
            });
        } catch (Exception e) {
            logger.error("Error querying Pinecone", e);
            return List.of();
        }
    }

    /**
     * Delete a vector from Pinecone.
     */
    public void deleteVector(String itemId) {
        try {
            String endpoint =
                    String.format(
                            "https://%s-%s.pinecone.io/vectors/delete",
                            indexName, environment);

            Map<String, Object> request = new HashMap<>();
            request.put("namespace", "wardrobe");
            request.put("ids", List.of(itemId));

            String jsonPayload = objectMapper.writeValueAsString(request);

            HttpClient httpClient = HttpClients.createDefault();
            HttpPost httpPost = new HttpPost(endpoint);
            httpPost.setHeader("Api-Key", pineconeApiKey);
            httpPost.setHeader("Content-Type", "application/json");
            httpPost.setEntity(new StringEntity(jsonPayload, ContentType.APPLICATION_JSON));

            httpClient.execute(httpPost, response -> {
                logger.info("Deleted vector for item {} with status: {}", itemId, response.getCode());
                return null;
            });
        } catch (Exception e) {
            logger.error("Error deleting vector from Pinecone for item: {}", itemId, e);
        }
    }
}
