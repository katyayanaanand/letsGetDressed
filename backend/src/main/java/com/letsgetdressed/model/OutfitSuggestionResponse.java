package com.letsgetdressed.model;

import java.util.ArrayList;
import java.util.List;

public class OutfitSuggestionResponse {

    private List<WardrobeItem> suggestedItems = new ArrayList<>();
    private List<String> shoppingSuggestions = new ArrayList<>();
    private String message;

    public OutfitSuggestionResponse() {
    }

    public List<WardrobeItem> getSuggestedItems() {
        return suggestedItems;
    }

    public void setSuggestedItems(List<WardrobeItem> suggestedItems) {
        this.suggestedItems = suggestedItems == null ? new ArrayList<>() : suggestedItems;
    }

    public List<String> getShoppingSuggestions() {
        return shoppingSuggestions;
    }

    public void setShoppingSuggestions(List<String> shoppingSuggestions) {
        this.shoppingSuggestions = shoppingSuggestions == null ? new ArrayList<>() : shoppingSuggestions;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}