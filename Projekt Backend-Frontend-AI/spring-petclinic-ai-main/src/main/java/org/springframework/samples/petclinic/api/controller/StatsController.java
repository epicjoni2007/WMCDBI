package org.springframework.samples.petclinic.api.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.samples.petclinic.owner.OwnerRepository;
import org.springframework.samples.petclinic.owner.PetRepository;
import org.springframework.samples.petclinic.visit.VisitRepository;
import org.springframework.samples.petclinic.vet.VetRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/stats")
public class StatsController {

	private final OwnerRepository ownerRepository;

	private final PetRepository petRepository;

	private final VetRepository vetRepository;

	private final VisitRepository visitRepository;

	public StatsController(OwnerRepository ownerRepository, PetRepository petRepository, VetRepository vetRepository,
			VisitRepository visitRepository) {
		this.ownerRepository = ownerRepository;
		this.petRepository = petRepository;
		this.vetRepository = vetRepository;
		this.visitRepository = visitRepository;
	}

	@GetMapping("/summary")
	public ResponseEntity<Map<String, Object>> summary(@RequestParam(value = "date", required = false) String date) {
		Map<String, Object> out = new HashMap<>();
		long ownersCount = ownerRepository.count();
		long petsCount = petRepository.count();
		long vetsCount = vetRepository.count();
		long totalVisits = visitRepository.count();
		long visitsOnDate = 0L;
		if (date != null && !date.isEmpty()) {
			LocalDate d = LocalDate.parse(date);
			visitsOnDate = visitRepository.countByDate(d);
		}
		out.put("ownersCount", ownersCount);
		out.put("petsCount", petsCount);
		out.put("vetsCount", vetsCount);
		out.put("totalVisits", totalVisits);
		out.put("visitsOnDate", visitsOnDate);
		return ResponseEntity.ok(out);
	}

}
