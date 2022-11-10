[Mesh]
  [top_block]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 30
    ny = 30
    nz = 2
    xmin = -0.25
    xmax = 10.25
    ymin = -0.25
    ymax = 10.25
    zmin = -.5
    zmax =0
  []
  [top_block_sidesets]
    type = RenameBoundaryGenerator
    input = top_block
    old_boundary = '0 1 2 3 4 5'
    new_boundary = 'top_bottom top_back top_right top_front top_left top_top'
  []
  [top_block_id]
    type = SubdomainIDGenerator
    input = top_block_sidesets
    subdomain_id = 1
  []
  [bottom_block]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 30
    ny = 30
    nz = 2
    xmin =.25
    xmax = 9.75
    ymin = .25
    ymax = 9.75
    zmin = 1
    zmax = 1.5
  []
  [bottom_block_id]
    type = SubdomainIDGenerator
    input = bottom_block
    subdomain_id = 2
  []
  [bottom_block_change_boundary_id]
    type = RenameBoundaryGenerator
    input = bottom_block_id
    old_boundary = '0 1 2 3 4 5'
    new_boundary = '100 101 102 103 104 105'
  []
  
    [helper]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 1
    ny = 1
    nz = 1
    xmin = 0
    xmax =10
    ymin = 0
    ymax = 10
    zmin = .45
    zmax = .55
    elem_type = HEX8
  []
  [helper_block_id]
    type = SubdomainIDGenerator
    input = helper
    subdomain_id = 3
  []
  [helper_block_change_boundary_id1]
    type = RenameBoundaryGenerator
    input = helper_block_id
    old_boundary = '0 1 2 3 4 5'
    new_boundary = 'helper_bottom helper_back helper_right helper_front helper_left helper_top'
  []
    [helper_block_change_boundary_id]
    type = RenameBoundaryGenerator
    input = helper_block_change_boundary_id1
    old_boundary = '0 1 2 3 4 5'
    new_boundary = '200 201 202 203 204 205'
  []
  [combined]
    type = MeshCollectionGenerator
    inputs = 'top_block_id bottom_block_change_boundary_id helper_block_change_boundary_id'
  []
  [block_rename]
    type = RenameBlockGenerator
    input = combined
    old_block = '1 2'
    new_block = 'top_block bottom_block'
  []
  patch_size=900
  parthc_upadate_strategy=auto
[]  

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Variables]
  [disp_x]
    order = FIRST
    family = LAGRANGE
  []
  [disp_y]
    order = FIRST
    family = LAGRANGE
  []
  [disp_z]
    order = FIRST
    family = LAGRANGE
  []
[]

[AuxVariables]
  [./vel_x]
  [../]
  [./accel_x]
  [../]
  [./vel_y]
  [../]
  [./accel_y]
  [../]
  [./vel_z]
  [../]
  [./accel_z]
  [../]
[]  

[Kernels]
  [./dynamicx]
    type=ADDynamicStressDivergenceTensors
    component=0
    variable=disp_x
    use_displaced_mesh = true
    use_automatic_differentiation = true
    zeta =0.0016
    alpha = -.25
  [../]
    [./dynamicy]
    type=ADDynamicStressDivergenceTensors
    component=1
    variable=disp_y
    use_displaced_mesh = true
    use_automatic_differentiation = true
    zeta =0.0016
    alpha = -.25
  [../]
    [./dynamicz]
    type=ADDynamicStressDivergenceTensors
    component=2
    variable=disp_z
    use_displaced_mesh = true
    use_automatic_differentiation = true
    zeta =0.0016
    alpha = -.25
  [../]
  [./inertia_x]
    type = InertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    beta = 0.4
    gamma = 0.75
    eta=.0075
    alpha = -.25
  [../]
  [./inertia_y]
    type = InertialForce
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    beta = 0.4
    gamma = 0.75
    eta=0.0075
    alpha = -.25
  [../]
  [./inertia_z]
    type = InertialForce
    variable = disp_z
    velocity = vel_z
    acceleration = accel_z
    beta = 0.4
    gamma = 0.75
    eta = .0075
    alpha = -.25
  [../]
[]

[AuxKernels]
  [./accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    beta = 0.4
    execute_on = timestep_end
  [../]
  [./vel_x]
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    gamma = 0.75
    execute_on = timestep_end
  [../]
  [./accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    beta = 0.4
    execute_on = timestep_end
  [../]
  [./vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    gamma = 0.75
    execute_on = timestep_end
  [../]
  [./accel_z]
    type = NewmarkAccelAux
    variable = accel_z
    displacement = disp_z
    velocity = vel_z
    beta = 0.4
    execute_on = timestep_end
  [../]
  [./vel_z]
    type = NewmarkVelAux
    variable = vel_z
    acceleration = accel_z
    gamma = 0.75
    execute_on = timestep_end
  [../]
[]

[Functions]
  [rampLinear]
    type = ParsedFunction
    value=-1*1e5*t*t*1e-3
[]

[]

[BCs]
     [Pressure]
	        [stress]
        boundary = 'back top_top'
        function=rampLinear
        use_automatic_differentiation = true
        use_displaced_mesh = true
        hht_alpha=-.25
    []

    []

  [hold_x]
    type =ADDirichletBC
    variable = disp_x
    boundary = 'right helper_right top_right left helper_left top_left top top_front helper_front bottom top_back helper_back'
    value = 0.0
  []
  [hold_y]
    type = ADDirichletBC
    variable = disp_y
boundary = 'right helper_right top_right left helper_left top_left top top_front helper_front bottom top_back helper_back'
    value = 0.0
  []
  [hold_z]
    type = ADDirichletBC
    variable = disp_z
boundary = 'right helper_right top_right left helper_left top_left top top_front helper_front bottom top_back helper_back'
    value = 0.0
  []

[]


[Contact]


    [contact1]
    primary = 'back'
    secondary = 'top_top'
    model=frictionless
    #model = coulomb
    #friction_coefficient = 0.01
    penalty = 4e6
    formulation=penalty
    normalize_penalty=True
    normal_smoothing_distance = 0.1
    newmark_beta = 0.4
    newmark_gamma = 0.75
    []





[Materials]
  [strain]
    type=H_ADComputeFiniteStrain
    decomposition_method=EigenSolution   []
  [./elasticity_tensor]
    type = ADComputeElasticityTensor
    C_ijkl = '1 1 1 1 1 1 1 1 1'
    fill_method = symmetric9
  [../]
  [elasitc_stress1]
    type=H_ADComputeFiniteStrainElasticStress
    large_rotations=False
    mu=.116e3  # for smaller stains use paramer fit over range of 0-30% which is .116 #even better .1 to .4 which is .122
    kappa=.116e5
  [] 
  [./density1]
    type = GenericConstantMaterial
    prop_names = density
    #block='actuator base'
    #volume is 19701 mm^3
    #mass is 76.6/4 g (19.15g)
    prop_values = .972e-6
  [../]

[]

[Executioner]
  type = Transient
  solve_type=PJFNK
  nl_rel_tol = 1e-4
  nl_abs_tol =8e-4
  l_max_its = 5
  l_tol = 1e-7
  nl_max_its = 15

  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap -ksp_gmres_restart'
  petsc_options_value = 'asm lu 20 151'
  
  line_search='contact'
  nl_forced_its=2 ################## don't set this high if using an adaptive timestepper
  
  automatic_scaling=true
  compute_scaling_once=false
  start_time=0.0
  end_time=.25
  [TimeStepper]
    type = ConstantDT
    #dt=.005
    #type = IterationAdaptiveDT
    #growth_factor=1.0
    #optimal_iterations = 8
    dt = .01
  []
  [TimeIntegrator]
  	type=ImplicitEuler
  []
  dtmin=.001
[]


[Postprocessors]


[]

[Outputs]
  exodus = true
   execute_on = 'INITIAL TIMESTEP_END'
  [pgraph]
    type = PerfGraphOutput
     execute_on = 'INITIAL TIMESTEP_END'
  []
[]
