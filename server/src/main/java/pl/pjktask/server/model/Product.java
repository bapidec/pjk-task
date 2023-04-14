package pl.pjktask.server.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(nullable = false)
    private long product_id;

    @Column(nullable = false)
    private String product_name;

    @Column(nullable = false, scale = 2)
    private float price;

    private String country_of_origin;

    @Column(nullable = false)
    private String category;

    @Column(nullable = false)
    private boolean available;

}
