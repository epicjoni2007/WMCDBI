package org.springframework.samples.petclinic.visit;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.time.LocalDate;
import org.springframework.samples.petclinic.owner.Visit;

public interface VisitRepository extends JpaRepository<Visit, Integer> {

	@Query("SELECT FUNCTION('DATE_FORMAT', v.date, '%Y-%m'), COUNT(v) FROM Visit v GROUP BY FUNCTION('DATE_FORMAT', v.date, '%Y-%m')")
	List<Object[]> countVisitsByMonth();

	@Query("SELECT COUNT(v) FROM Visit v WHERE v.date = :date")
	long countByDate(LocalDate date);

}
