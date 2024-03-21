package com.ssafy.coffee;

import com.ssafy.coffee.global.util.DataUtil;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class CoffeeApplication {
    private static DataUtil dataUtil;
    public static void main(String[] args) {
        SpringApplication.run(CoffeeApplication.class, args);
    }
}
