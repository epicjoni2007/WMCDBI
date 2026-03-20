package org.springframework.samples.petclinic.stats;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.samples.petclinic.owner.PetRepository;
import org.springframework.samples.petclinic.visit.VisitRepository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/stats")
public class StatsRestController {

	@Autowired
	private PetRepository petRepository;

	@Autowired
	private VisitRepository visitRepository;

	@GetMapping("/pets/count")
	public Map<String, Long> getPetCount() {
		long count = petRepository.count();
		Map<String, Long> result = new HashMap<>();
		result.put("count", count);
		return result;
	}

	@GetMapping("/pets/species")
	public Map<String, Long> getPetsBySpecies() {
		List<Object[]> speciesCounts = petRepository.countPetsBySpecies();
		Map<String, Long> result = new HashMap<>();
		for (Object[] row : speciesCounts) {
			result.put((String) row[0], (Long) row[1]);
		}
		return result;
	}

	@GetMapping("/owners/top")
	public List<Object[]> getTopOwners() {
		return petRepository.findTopOwnersByPetCount();
	}

	@GetMapping("/visits/monthly")
	public Map<String, Long> getMonthlyVisits() {
		List<Object[]> monthlyVisits = visitRepository.countVisitsByMonth();
		Map<String, Long> result = new HashMap<>();
		for (Object[] row : monthlyVisits) {
			result.put((String) row[0], (Long) row[1]);
		}
		return result;
	}

}
