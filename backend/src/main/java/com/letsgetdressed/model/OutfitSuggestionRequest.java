package com.letsgetdressed.model;

import java.util.ArrayList;
import java.util.List;

public class OutfitSuggestionRequest {

    private String occasion;
    private String season;
    private List<String> preferredColors = new ArrayList<>();
    private boolean allowShoppingSuggestions = false;

    public OutfitSuggestionRequest() {
    }

    public String getOccasion() {
        return occasion;
    }

    public void setOccasion(String occasion) {
        this.occasion = occasion;
    }

    public String getSeason() {
        return season;
    }

    public void setSeason(String season) {
        this.season = season;
    }

    public List<String> getPreferredColors() {
        return preferredColors;
    }

    public void setPreferredColors(List<String> preferredColors) {
        this.preferredColors = preferredColors == null ? new ArrayList<>() : preferredColors;
    }

    public boolean isAllowShoppingSuggestions() {
        return allowShoppingSuggestions;
    }

    public void setAllowShoppingSuggestions(boolean allowShoppingSuggestions) {
        this.allowShoppingSuggestions = allowShoppingSuggestions;
    }
}