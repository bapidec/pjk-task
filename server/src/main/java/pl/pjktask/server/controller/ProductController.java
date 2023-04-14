package pl.pjktask.server.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import pl.pjktask.server.model.Product;
import pl.pjktask.server.repository.ProductRepository;

import java.util.List;

@RestController
@RequestMapping("/api/products")
public class ProductController{

    @Autowired
    private ProductRepository productRepository;

    @GetMapping
    public List<Product> getAllProducts() {
        return (List<Product>) productRepository.findAll();
    }

}
