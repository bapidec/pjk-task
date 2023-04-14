package pl.pjktask.server.repository;

import org.springframework.data.repository.CrudRepository;
import pl.pjktask.server.model.Product;

public interface ProductRepository extends CrudRepository<Product, Long> {

}
