package com.letsgetdressed.controller;

import com.letsgetdressed.model.OutfitSuggestionRequest;
import com.letsgetdressed.model.OutfitSuggestionResponse;
import com.letsgetdressed.service.OutfitSuggestionService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class SuggestionController {

    private final OutfitSuggestionService outfitSuggestionService;

    public SuggestionController(OutfitSuggestionService outfitSuggestionService) {
        this.outfitSuggestionService = outfitSuggestionService;
    }

    @PostMapping("/suggestions")
    public OutfitSuggestionResponse getSuggestions(@RequestBody(required = false) OutfitSuggestionRequest request) {
        OutfitSuggestionRequest safeRequest = request == null ? new OutfitSuggestionRequest() : request;
        return outfitSuggestionService.suggestOutfit(safeRequest);
    }
}