package com.letsgetdressed.controller;

import com.letsgetdressed.model.WardrobeItem;
import com.letsgetdressed.service.WardrobeService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class WardrobeController {

    private final WardrobeService wardrobeService;

    public WardrobeController(WardrobeService wardrobeService) {
        this.wardrobeService = wardrobeService;
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("ok");
    }

    @GetMapping("/wardrobe")
    public List<WardrobeItem> getWardrobe() {
        return wardrobeService.getAllItems();
    }

    @GetMapping("/wardrobe/{id}")
    public ResponseEntity<WardrobeItem> getWardrobeItem(@PathVariable String id) {
        WardrobeItem item = wardrobeService.getItemById(id);
        if (item == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(item);
    }

    @PostMapping("/wardrobe")
    public ResponseEntity<WardrobeItem> createWardrobeItem(@Valid @RequestBody WardrobeItem item) {
        WardrobeItem createdItem = wardrobeService.addItem(item);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdItem);
    }

    @DeleteMapping("/wardrobe/{id}")
    public ResponseEntity<Void> archiveWardrobeItem(@PathVariable String id) {
        WardrobeItem archived = wardrobeService.archiveItem(id);
        if (archived == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/wardrobe/search/category")
    public List<WardrobeItem> searchByCategory(@RequestParam String category) {
        return wardrobeService.getItemsByCategory(category);
    }

    @GetMapping("/wardrobe/search/season")
    public List<WardrobeItem> searchBySeason(@RequestParam String season) {
        return wardrobeService.getItemsBySeason(season);
    }

    @GetMapping("/wardrobe/search/occasion")
    public List<WardrobeItem> searchByOccasion(@RequestParam String occasion) {
        return wardrobeService.getItemsByOccasion(occasion);
    }

    @GetMapping("/wardrobe/search/color")
    public List<WardrobeItem> searchByColor(@RequestParam String color) {
        return wardrobeService.getItemsByColor(color);
    }
}