[Mesh]
    file='../../mesh/full_finger_sliding_v3.msh'
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
  [gravity_x]
  type = Gravity
  variable = disp_x
  #value =0
  #value=9810
  value=29810
[]

[gravity_y]
  type = Gravity
  variable = disp_y
  block=actuator
  value =-109810
[]
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
    value=-1*max(1e5*t,1e5*.12)
[]
 [sg_f1]
    type = ParsedFunction
    vals = sg1_area
    vars = area
    value = '-1e3/area'
  []
  [sg_f1c]
    type = ParsedFunction
    vals = sg1c_area
    vars = area
    value = '-1e3/area'
  []
[]

[BCs]
     [Pressure]
        [stress]
        boundary = 'actuator_front'
        #function=rampLinear
        factor=0
        use_automatic_differentiation = true
        use_displaced_mesh = true
        hht_alpha=-.25
    []
    #superglue pressures
    	[sg1]
    	    	boundary='actuator_front'
    		function=sg_f1
    		#factor=0
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	[sg1c]
    	    	boundary='mass_back'
    		function=sg_f1c
    		#factor=0
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]

    []

  [hold_x]
    type =ADDirichletBC
    variable = disp_x
    boundary = 'base_top actuator_back'
    value = 0.0
  []
  [hold_y]
    type = ADDirichletBC
    variable = disp_y
    boundary = 'base_top actuator_back'
    value = 0.0
  []
  [hold_z]
    type = ADDirichletBC
    variable = disp_z
    boundary = 'base_top actuator_back'
    value = 0.0
  []

[]


[Contact]

   [superglue1]
    primary = 'actuator_front'
    secondary = 'mass_back'
    model = glued
    penalty = 0.5e6
    formulation=penalty
    normalize_penalty=True
    normal_smoothing_distance = 0.1
    newmark_beta = 0.4
    newmark_gamma = 0.75
    []
    
    
    [base_support1]
    primary = 'base_top'
    secondary = 'actuator_bottom'
    model = coulomb
    friction_coefficient = 0.2
    penalty = 4e6
    formulation=penalty
    normalize_penalty=True
    normal_smoothing_distance = 0.1
    newmark_beta = 0.4
    newmark_gamma = 0.75
    []

#    [base_support2]
#    primary = 'base_top'
#    secondary = 'mass_bottom'
#    model=frictionless
#    #model = coulomb
#    #friction_coefficient = 0.01
#    penalty = 4e6
#    formulation=penalty
#    normalize_penalty=True
#    normal_smoothing_distance = 0.1
#    newmark_beta = 0.4
#    newmark_gamma = 0.75
#    []
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
    block='actuator base'
    #volume is 19701 mm^3
    #mass is 76.6/4 g (19.15g)
    prop_values = .972e-6
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
  end_time=30
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
    	    boundary = actuator_front
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[sg1c_area]
	    type = AreaPostprocessor
    	    boundary = mass_back
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
[]

[Outputs]
  exodus = true
   execute_on = 'INITIAL TIMESTEP_END'
  [pgraph]
    type = PerfGraphOutput
     execute_on = 'INITIAL TIMESTEP_END'
  []
[]
