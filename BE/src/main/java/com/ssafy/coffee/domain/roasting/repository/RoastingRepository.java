package com.ssafy.coffee.domain.roasting.repository;

import com.ssafy.coffee.domain.roasting.entity.Roasting;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RoastingRepository extends JpaRepository<Roasting, Long> {

}
