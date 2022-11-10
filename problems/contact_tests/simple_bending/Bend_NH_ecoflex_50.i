[Mesh]
    #file='../mesh/simple_bend_superglue2.msh'
    file='../../../mesh/half_bend_mesh_v3.e'
    dim=3
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
    value=.2e5*t
[]
 [sg_f1]
    type = ParsedFunction
    vals = sg1_area
    vars = area
    value = '-1e0/area'
  []
  [sg_f1c]
    type = ParsedFunction
    vals = sg1c_area
    vars = area
    value = '-1e0/area'
  []
   [sg_f2]
    type = ParsedFunction
    vals = sg2_area
    vars = area
    value = '-1e0/area'
  []
  [sg_f2c]
    type = ParsedFunction
    vals = sg2c_area
    vars = area
    value = '-1e0/area'
  []
   [sg_f3]
    type = ParsedFunction
    vals = sg3_area
    vars = area
    value = '-1e0/area'
  []
  [sg_f3c]
    type = ParsedFunction
    vals = sg3c_area
    vars = area
    value = '-1e0/area'
  []
   [sg_f4]
    type = ParsedFunction
    vals = sg4_area
    vars = area
    value = '-1e0/area'
  []
  [sg_f4c]
    type = ParsedFunction
    vals = sg4c_area
    vars = area
    value = '-1e0/area'
  []
[]

[BCs]
     [Pressure]
        [stress]
        boundary = 'Inner_cavity'
        function=rampLinear
        use_automatic_differentiation = true
        use_displaced_mesh = true
        hht_alpha=-.25
    []
    #superglue pressures
    	[sg1]
    	    	boundary='SG1'
    		function=sg_f1
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	[sg1c]
    	    	boundary='SG1C'
    		function=sg_f1c
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	    	[sg2]
    	    	boundary='SG2'
    		function=sg_f2
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	[sg2c]
    	    	boundary='SG2C'
    		function=sg_f2c
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	    	[sg3]
    	    	boundary='SG3'
    		function=sg_f3
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	[sg3c]
    	    	boundary='SG3C'
    		function=sg_f3c
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	    	[sg4]
    	    	boundary='SG4'
    		function=sg_f4
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	[sg4c]
    	    	boundary='SG4C'
    		function=sg_f4c
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    []

  [hold_x]
    type =ADDirichletBC
    variable = disp_x
    boundary = 'body_base midpoint_x'
    value = 0.0
  []
  [hold_y]
    type = ADDirichletBC
    variable = disp_y
    boundary = 'body_base'
    value = 0.0
  []
  [hold_z]
    type = ADDirichletBC
    variable = disp_z
    boundary = 'body_base'
    value = 0.0
  []

[]


[Contact]
  [b1]
    primary = 'Body1 Body2 Body3 Body4 Body5 Body6 Body7 Body8'
    secondary = 'Body1C Body2C Body3C Body4C Body5C Body6C Body7C Body8C'
    model = frictionless
    penalty = .01e6 ################### this value needs to be inreased from .1e5, there is significant penetration at higher deformations. #########################
    formulation=penalty
    normalize_penalty=True
    normal_smoothing_distance = 0.1
    newmark_beta = 0.4
    newmark_gamma = 0.75
    []
   [superglue1]
    primary = 'SG1 SG2 SG3 SG4'
    secondary = 'SG1C SG2C SG3C  SG4C'
    model = glued
    penalty = .2e6
    formulation=penalty
    normalize_penalty=True
    normal_smoothing_distance = 0.1
    newmark_beta = 0.4
    newmark_gamma = 0.75
    []
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
  [elasitc_stress]
    type = H2_ADComputeFiniteStrainElasticStress
    mu=.0224e6  # compiled with proper NH formulaiton
    kappa=.0224e8
  []
    [./density1]
    type = GenericConstantMaterial
    prop_names = density
    prop_values = 1000e-9
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
  
  line_search='none'
  nl_forced_its=2 ################## don't set this high if using an adaptive timestepper
  
  automatic_scaling=true
  compute_scaling_once=false
  start_time=0.0
  end_time=30
  [TimeStepper]
    #type = ConstantDT
    #dt=.005
    type = IterationAdaptiveDT
    growth_factor=1.2
    optimal_iterations = 8
    dt = .001
  []
  [TimeIntegrator]
  	type=ImplicitEuler
  []
  dtmin=.001
[]


[Postprocessors]
  [max]
  type=NodalExtremeValue
  variable=disp_y
  []
  [min]
  type=NodalExtremeValue
  variable=disp_y
  value_type=min
  []
  [maxx]
  type=NodalExtremeValue
  variable=disp_x
  []
  [minx]
  type=NodalExtremeValue
  variable=disp_x
  value_type=min
  []
  
  #superglue post processors
  	[sg1_area]
	    type = AreaPostprocessor
    	    boundary = SG1
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[sg1c_area]
	    type = AreaPostprocessor
    	    boundary = SG1C
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	  	[sg2_area]
	    type = AreaPostprocessor
    	    boundary = SG2
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[sg2c_area]
	    type = AreaPostprocessor
    	    boundary = SG2C
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	  	[sg3_area]
	    type = AreaPostprocessor
    	    boundary = SG3
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[sg3c_area]
	    type = AreaPostprocessor
    	    boundary = SG3C
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	  	[sg4_area]
	    type = AreaPostprocessor
    	    boundary = SG4
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[sg4c_area]
	    type = AreaPostprocessor
    	    boundary = SG4C
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
[]

[Outputs]
  exodus = true
   execute_on = 'INITIAL TIMESTEP_END'
     [checkpoint]
     type=Checkpoint
     num_files=2
     interval=25
  []
  [pgraph]
    type = PerfGraphOutput
     execute_on = 'INITIAL TIMESTEP_END'
  []
[]
