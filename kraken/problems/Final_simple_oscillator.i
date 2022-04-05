[Mesh]
    file='../../../mesh/single_with_weight.msh'
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
    zeta =0.015
    alpha = -.25
    block='w'
  [../]
    [./dynamicy]
    type=ADDynamicStressDivergenceTensors
    component=1
    variable=disp_y
    use_displaced_mesh = true
    use_automatic_differentiation = true
    zeta =0.015
    alpha = -.25
    block='w'
  [../]
    [./dynamicz]
    type=ADDynamicStressDivergenceTensors
    component=2
    variable=disp_z
    use_displaced_mesh = true
    use_automatic_differentiation = true
    zeta =0.0015
    alpha = -.25
    block='w'
  [../]
    [./adynamicx]
    type=ADDynamicStressDivergenceTensors
    component=0
    variable=disp_x
    use_displaced_mesh = true
    use_automatic_differentiation = true
    zeta =0.015
    alpha = -.25
    block='a1'
  [../]
    [./adynamicy]
    type=ADDynamicStressDivergenceTensors
    component=1
    variable=disp_y
    use_displaced_mesh = true
    use_automatic_differentiation = true
    zeta =0.015
    alpha = -.25
    block='a1'
  [../]
    [./adynamicz]
    type=ADDynamicStressDivergenceTensors
    component=2
    variable=disp_z
    use_displaced_mesh = true
    use_automatic_differentiation = true
    zeta =0.015
    alpha = -.25
    block='a1'
  [../]
    [./inertia_x]
    type = InertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    beta = 0.4
    gamma = 0.75
    eta=.069
    alpha = -.25
  [../]
  [./inertia_y]
    type = InertialForce
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    beta = 0.4
    gamma = 0.75
    eta=0.069
    alpha = -.25
  [../]
  [./inertia_z]
    type = InertialForce
    variable = disp_z
    velocity = vel_z
    acceleration = accel_z
    beta = 0.4
    gamma = 0.75
    eta = .069
    alpha = -.25
  [../]
  
    [./gravity_x]
    type = Gravity
    variable = disp_x
    value =9800
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
  [rampexp]
      type = ParsedFunction
      value=.027e4*500*(1-exp(-1*t/4))
  []
  [./rampLinear]
    type = ParsedFunction
    value=.027e4*t*5*5*5
  []  
    #superglue functions
  [a_regulator]
    type = ParsedFunction
    vals = a_area
    vars = area
    value = '-5e6/area'
  []
  [w_regulator]
    type = ParsedFunction
    vals = w_area
    vars = area
    value = '-5e6/area'
  []
  [inner_slower]
    type = ParsedFunction
    value=-2.4*max(.011e3*(.25-t),0)
  []
    [./inner_slower2]
    type=PiecewiseLinear
    x='0 .1 .2 .3  30'
    y='0 -5.5  0   0  0'
  [] 
[]


[Contact]
#actuator 1 connector 1
  [a11]
    secondary = actuator_contact
    primary = weight_contact
    model = glued
    penalty = 1e6
    normal_smoothing_distance = 0.001
    []
[]


[BCs]
    [Pressure]
        [stress1]
        boundary=inner1
        function=inner_slower2
        #factor=0
        disp_x = disp_x
        disp_y = disp_y
        disp_z = disp_z
        alpha = -0.25
        use_automatic_differentiation = true
    	[]
    	
    	    	#superglue pressures
    	[a_regulation]
    		boundary='actuator_contact'
    		#function=a_regulator
    		factor=0
        	disp_x = disp_x
        	disp_y = disp_y
        	disp_z = disp_z
    		alpha = -.25
    		use_automatic_differentiation = true
        []
        [w_regulation]
   		boundary='weight_contact'
    		#function=w_regulator
    		factor=0
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
  [hold_z]
    type = DirichletBC
    variable = disp_z
    boundary = 'base'
    value = 0.0
  []
  [planar_constraint]
    type = DirichletBC
    variable = disp_y
    boundary = 'plane'
    value = 0.0
  []

[]

[Materials]
  [strain1]
   type=Custom_ADComputeFiniteStrain
    displacements='disp_x disp_y disp_z'
   block='a1'
  []
  [strain2]
    type = ADComputeFiniteStrain
    displacements = 'disp_x disp_y disp_z'
    block='w'
  []
  [elasitc_stress1]
    type = AD_NH_V6
   block='a1'
    
    #based on material prop conversion
    compressable=TRUE
    
    mu=.010e3
    kappa=.010e5
  [] 
  [elasitc_stress2]
    type = ADComputeFiniteStrainElasticStress
    block='w'
  [] 
    [./elasticity_tensor1]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 10e3
    poissons_ratio = .3
    block='w'
  [../]
  [./density1]
    type = GenericConstantMaterial
    prop_names = density
    block='a1'
    prop_values = 1070e-9
  [../]
    [./density2]
    type = GenericConstantMaterial
    prop_names = density
    block='w'
    prop_values = 3940e-9
    #3400 equals 50g of mass for 1/2 of 100g weight
    #3940 equals 58g of mass for 1/2 of 100g weight and 1/2 of 16g end cap and markers
   [../]
  
[]


[Executioner]
  [TimeIntegrator]
    type=Heun
  []
  type = Transient
  solve_type=PJFNK  
  nl_rel_tol = 10e-2
  nl_abs_tol =5e-6
  l_max_its = 15
  l_tol = 1e-10
  nl_max_its = 20
  
  
  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap -ksp_gmres_restart'
  petsc_options_value = 'asm lu 20 151'
  
  
  automatic_scaling=true
  compute_scaling_once=false
  
  start_time=0.0
  end_time=30
  [TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 14
    dt = .02
    cutback_factor=.99
    growth_factor=1.001
  []
  dtmin=.001
[]

[Postprocessors]
	#superglue postprocessors
	[a_area]
	    type = AreaPostprocessor
    	    boundary = actuator_contact
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[w_area]
	    type = AreaPostprocessor
    	    boundary = weight_contact
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
[]

[Outputs]
  execute_on = 'INITIAL TIMESTEP_END'
  exodus = true
  perf_graph = true
[]
