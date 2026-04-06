package com.letsgetdressed.repository;

import com.letsgetdressed.model.WardrobeItem;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface WardrobeItemRepository extends JpaRepository<WardrobeItem, String> {

    List<WardrobeItem> findByArchivedFalseOrderByCreatedAtDesc();

    @Query("SELECT w FROM WardrobeItem w WHERE w.archived = false AND LOWER(w.category) = LOWER(:category)")
    List<WardrobeItem> findByCategory(@Param("category") String category);

    @Query("SELECT w FROM WardrobeItem w WHERE w.archived = false AND LOWER(w.season) = LOWER(:season)")
    List<WardrobeItem> findBySeason(@Param("season") String season);

    @Query("SELECT w FROM WardrobeItem w WHERE w.archived = false AND LOWER(w.occasion) = LOWER(:occasion)")
    List<WardrobeItem> findByOccasion(@Param("occasion") String occasion);

    @Query("SELECT w FROM WardrobeItem w WHERE w.archived = false AND LOWER(w.color) LIKE LOWER(CONCAT('%', :color, '%'))")
    List<WardrobeItem> findByColorContaining(@Param("color") String color);

    @Query("SELECT w FROM WardrobeItem w WHERE w.archived = false")
    List<WardrobeItem> findAllActive();
}
