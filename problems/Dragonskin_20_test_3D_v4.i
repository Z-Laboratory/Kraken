[Mesh]
    file='../../../mesh/full_finger.msh'
    dim=3
    use_displaced_mesh = true
    construct_side_list_from_node_list=True
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
    zeta =.00098
    alpha = -.25
    block='mass'
  [../]
    [./dynamicy]
    type=ADDynamicStressDivergenceTensors
    component=1
    variable=disp_y
    use_displaced_mesh = true
    use_automatic_differentiation = true
    zeta =0.004
    alpha = -.25
    block='mass'
  [../]
    [./dynamicz]
    type=ADDynamicStressDivergenceTensors
    component=2
    variable=disp_z
    use_displaced_mesh = true
    use_automatic_differentiation = true
    zeta =0.004
    alpha = -.25
    block='mass'
  [../]
    [./adynamicx]
    type=ADDynamicStressDivergenceTensors
    component=0
    variable=disp_x
    use_displaced_mesh = true
    use_automatic_differentiation = true
    zeta = 0.0098
    alpha = -.25
    block='actuator'
  [../]
    [./adynamicy]
    type=ADDynamicStressDivergenceTensors
    component=1
    variable=disp_y
    use_displaced_mesh = true
    use_automatic_differentiation = true
    zeta =0.004
    alpha = -.25
    block='actuator'
  [../]
    [./adynamicz]
    type=ADDynamicStressDivergenceTensors
    component=2
    variable=disp_z
    use_displaced_mesh = true
    use_automatic_differentiation = true
    zeta =0.0041
    alpha = -.25
    block='actuator'
  [../]
    [./inertia_x]
    type = InertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    beta = 0.4
    gamma = 0.75
    eta=0 #0.2
    alpha = -.25
  [../]
  [./inertia_y]
    type = InertialForce
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    beta = 0.4
    gamma = 0.75
    eta=0 #0.2
    alpha = -.25
  [../]
  [./inertia_z]
    type = InertialForce
    variable = disp_z
    velocity = vel_z
    acceleration = accel_z
    beta = 0.4
    gamma = 0.75
    eta = 0 #0.2
    alpha = -.25
  [../]
  
    [./gravity_x]
    type = Gravity
    variable = disp_x
    value = 9810
    alpha=-.25
    #block='a1'
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
  [./rampLineary]
    type = ParsedFunction
    value=max(if(.04<=t,10*29e-2*(.40-t),0),0)
  [] 
  
  [./rampLinearz]
    type = ParsedFunction
    value=max(if(.24<=t,12*42e-2*(.72-t),0),0)
  [] 
  
  [./rampLinear2]
    type = ParsedFunction
    value=if(t<=.31,3e-2,0)
  [] 
    #superglue functions
  [a_regulator]
    type = ParsedFunction
    vals = a_area
    vars = area
    value = '-1e3/area'
  []
  [w_regulator]
    type = ParsedFunction
    vals = w_area
    vars = area
    value = '-1e3/area'
  []
[]


[Contact]
  [a11]  #actuator 1 connector 1
    secondary = ai
    primary = mi
    model = glued
    penalty = 1e3
    formulation=penalty
    normalize_penalty=True
    normal_smoothing_distance = 0.001
    []
[]


[BCs]
    [Pressure]
    	[s1]
        boundary=mass_x 
        function=rampLinear2
        #factor=0
        alpha = -0.25
        use_automatic_differentiation = true
    	[]
    	    	[s2]
        boundary=mass_y
        function=rampLineary
        #factor=0
        alpha = -0.25
        use_automatic_differentiation = true
    	[]
    	    	[s3]
        boundary=mass_z
        function=rampLinearz
        #factor=0
        alpha = -0.25
        use_automatic_differentiation = true
    	[]
    	    	#superglue pressures
    	[a_regulation]
    		boundary='ai'
    		function=a_regulator
    		#factor=0
        	disp_x = disp_x
        	disp_y = disp_y
        	disp_z = disp_z
    		alpha = -.25
    		use_automatic_differentiation = true
        []
        [w_regulation]
   		boundary='mi'
    		function=w_regulator
    		#factor=0
        	disp_x = disp_x
        	disp_y = disp_y
        	disp_z = disp_z
        	alpha = -.25
        	use_automatic_differentiation = true
        []
    [] 
 [hold_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'base'
    value = 0.0
  []
   [hold_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'base'
    value = 0.0
  []

    [planar_constraint2]
    type = DirichletBC
    variable = disp_z
    boundary = 'base'
    value = 0.0
  []

[]

[Materials]
  [strain1]
   type=H_ADComputeFiniteStrain
  []
  [elasitc_stress1]
    type=H_ADComputeFiniteStrainElasticStress
    large_rotations=False
    mu=.0967e3 #fit over 10% strain
    kappa=.0967e5
  []  
  [./density1]
    type = GenericConstantMaterial
    prop_names = density
    block='actuator'
    #volume is 19701 mm^3
    #mass is 76.6/4 g (19.15g)
    #prop_values = .972e-6
    #alt value
    prop_values = 1.05e-6
  [../]
    [./density2]
    type = GenericConstantMaterial
    prop_names = density
    block='mass'
    #volume is 2105.5 mm^3
    #mass is 118.8/4 g (29.7g)
    prop_values = 14.1e-6  
  [../]
  
[]


[Executioner]

  type = Transient
  solve_type=NEWTON
  nl_rel_tol = 2e-10
  nl_abs_tol =2e-13
  l_max_its = 5
  l_tol = 1e-4
  nl_max_its = 20
  nl_forced_its=3
  
  #petsc_options_iname = '-pc_type -pc_hypre_type -pc_hypre_boomeramg_strong_threshold'
  #petsc_options_value = 'hypre boomeramg .5'
  
  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap -ksp_gmres_restart'
  petsc_options_value = 'asm lu 2 151'
  
  #petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  #petsc_options_value = 'lu mumps'
  
  line_search=none
  
  automatic_scaling=true
  compute_scaling_once=false
  
  start_time=0.0
  end_time=6
  #[TimeStepper]
  #  #Iteration adaptive
  #  reject_large_step=True
  #  reject_step_threshold=.5
  #  type = IterationAdaptiveDT
  #  optimal_iterations = 8
  #  dt = .004166
  #  cutback_factor=.5
  #  growth_factor=2.0
  #[]
  dt=.02
  dtmin=.002
[]

[Postprocessors]
	#superglue postprocessors
	[a_area]
	    type = AreaPostprocessor
    	    boundary = ai
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[w_area]
	    type = AreaPostprocessor
    	    boundary = mi
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
[]

[Outputs]
  execute_on = 'INITIAL TIMESTEP_END'
  exodus = true
  perf_graph = true
[]
