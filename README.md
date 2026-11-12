# Model of Protein Binding-Site Evolution

**BindingSiteDevelopmentModel.jl**

## 1. Possible applications of the model

The model is intended as a computational framework for exploring the relationship between polymer sequence, conformational properties, and the development of functional binding sites.

Possible applications include:

- **Evolution of binding sites:** Use a Genetic Algorithm (GA) to evolve model protein sequences towards the formation of a binding site with a predefined geometry.
- **Stability versus function:** Investigate the balance between structural stability and functional optimization in model biopolymers.
- **Competing sequence families:** Identify and characterize different model sequence families that compete for the same function under a given set of environmental conditions.

## 2. Model development procedure

### 2.1. Enumeration of lattice chains of length N

Generate all self-avoiding lattice chains of length N and store their conformations in files. Record relevant information about the enumeration procedure, including computational requirements and the attrition rate as a function of chain length.

The proposed lattice model of protein folding is based on the **Tetrahedral BCC Chain Model (TBCM)**. Polymer conformations are generated using a three-state bond-continuation rule. This model preserves a fixed tetrahedral local geometry while allowing discrete conformational flexibility through transitions between eight possible body-diagonal bond orientations.

A detailed description of the TBCM model will be provided in the project documentation.

### 2.2. Genetic Algorithm for the evolution of model sequences

The Genetic Algorithm will be used to explore sequence space and identify sequences with a propensity to form functional binding sites.

1. **Initial population:** Generate an initial population of model sequences of length N. In the basic model, each sequence consists of three types of residues: *A*, *E*, and *C*. Here, *A* represents a hydrophobic residue, *E* represents a hydrophilic (polar) residue, and *C* represents a binding-site residue. At this schematic level, sequences can be considered simplified model peptides with the potential to bind a metal ion.

2. **Structural analysis:** Load the conformations generated in Section 2.1 and calculate their lattice contact maps and potential metal-binding sites. A potential binding site is defined as an unoccupied lattice node adjacent to at least two chain beads. The details of this procedure will be specified in the project documentation.

3. **Sequence threading and energy evaluation:** For each model conformation, evaluate the energies of all sequences by threading them onto the corresponding lattice chains. The energy of a sequence–conformation combination is calculated from the lattice contact map.

4. **Functional binding-site identification:** Evaluate the functional properties of each sequence–conformation combination by analyzing its potential binding sites. A potential binding site is considered functional if at least two adjacent chain beads are of type *C*.

5. **Fitness calculation:** Calculate the fitness of each sequence based on the statistical probability of conformations containing functional binding sites and the number of *C* residues participating in the binding site. Conformations with more *C* residues in the binding site receive a higher weight. The conformational probability distribution for a given sequence is calculated using Boltzmann statistics.

The precise definition of the fitness function, including the weighting of functional binding sites, will be developed further.

### 2.3. Analysis of model sequence evolution

*To be developed.*

Possible topics include the characterization of evolving sequence families, their convergence or divergence, and the relationship between sequence composition, structural stability, and binding-site formation.

### 2.4. Visualization of model structures

*To be developed.*

## 3. Proposed project structure

- `src/` – Source code for the project.
  - `ChainEnumerator/` – Functions for lattice-chain enumeration and associated input/output procedures.
  - `GA/` – Genetic Algorithm implementation and sequence input/output procedures.
  - `Visualization/` – Functions for visualization of model structures.
  - `Analysis/` – Functions for analyzing the evolution of model sequences.
- `data/` – Project data.
- `chain_storage/` – Storage for enumerated lattice chains (excluded from the GitHub repository).
- `test/` – Tests for the project.
- `docs/` – Project documentation.
- `examples/` – Examples illustrating the use of the model.

```
BindingSiteDevelopmentModel/
│
├── Project.toml
├── Manifest.toml
├── README.md
├── LICENSE
│
├── src/
│   ├── BindingSiteDevelopmentModel.jl
│   │
│   ├── LatticeModel/
│   │   ├── chain.jl
│   │   ├── geometry.jl
│   │   └── enumeration.jl
│   │
│   ├── SequenceModel/
│   │   ├── sequence.jl
│   │   └── population.jl
│   │
│   ├── StructuralAnalysis/
│   │   ├── contact_maps.jl
│   │   ├── binding_sites.jl
│   │   └── structural_descriptors.jl
│   │
│   ├── EnergyModel/
│   │   ├── interactions.jl
│   │   ├── energy.jl
│   │   └── thermodynamics.jl
│   │
│   ├── Evolution/
│   │   ├── genetic_algorithm.jl
│   │   ├── selection.jl
│   │   ├── mutation.jl
│   │   ├── crossover.jl
│   │   └── fitness.jl
│   │
│   ├── Analysis/
│   │   ├── sequence_analysis.jl
│   │   ├── population_analysis.jl
│   │   └── evolutionary_analysis.jl
│   │
│   ├── Visualization/
│   │   ├── lattice_visualization.jl
│   │   ├── chain_visualization.jl
│   │   └── binding_site_visualization.jl
│   │
│   └── IO/
│       ├── read_write_chains.jl
│       ├── read_write_sequences.jl
│       └── results.jl
│
├── test/
│   ├── runtests.jl
│   ├── test_lattice.jl
│   ├── test_enumeration.jl
│   ├── test_energy.jl
│   ├── test_binding_sites.jl
│   └── test_evolution.jl
│
├── data/
│   ├── input/
│   └── reference/
│
├── chain_storage/
│   └── .gitkeep
│
├── results/
│
├── examples/
│   ├── 01_chain_enumeration.jl
│   ├── 02_sequence_energy.jl
│   └── 03_binding_site_evolution.jl
│
├── docs/
│   ├── make.jl
│   └── src/
│
└── benchmarks/
    └── enumeration_benchmark.jl

```