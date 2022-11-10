[Mesh]
[m1]
 type = FileMeshGenerator
    file='../../mesh/full_gripper_all_v2.msh'
    dim=3
    patch_update_strategy=iteration
    patch_size=1
[]
[m2]
 type = FileMeshGenerator
    file='../../mesh/item.msh'
    dim=3
    patch_update_strategy=iteration
    patch_size=1
[]
[combo]
type=CombinerGenerator
inputs='m1 m2'
positions='0 0 0 0 3.25 0' ########## test if this is the same as previous
[]
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
    zeta =0.025
    alpha = -.25
  [../]
    [./dynamicy]
    type=ADDynamicStressDivergenceTensors
    component=1
    variable=disp_y
    use_displaced_mesh = true
    use_automatic_differentiation = true
    zeta =0.025
    alpha = -.25
  [../]
    [./dynamicz]
    type=ADDynamicStressDivergenceTensors
    component=2
    variable=disp_z
    use_displaced_mesh = true
    use_automatic_differentiation = true
    zeta =0.025
    alpha = -.25
  [../]
  [./inertia_x]
    type = InertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    beta = 0.4
    gamma = 0.75
    eta=.1
    alpha = -.25
  [../]
  [./inertia_y]
    type = InertialForce
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    beta = 0.4
    gamma = 0.75
    eta=0.1
    alpha = -.25
  [../]
  [./inertia_z]
    type = InertialForce
    variable = disp_z
    velocity = vel_z
    acceleration = accel_z
    beta = 0.4
    gamma = 0.75
    eta = .1
    alpha = -.25
  [../]
[gravity_z]
  type = Gravity
  variable = disp_z
  block=base
  value =-9810
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
    value=min(2e5*t,2e5*.4)
[]
  [rampLinear2]
    type = ParsedFunction
    value=min(2e5*t,2e5*.4)
[]
[top_motion]
    type = ParsedFunction
    value=max(0,25*(t-.1))
[]
############# a1 superglue funcitons #######################
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
  
  ############# a2 superglue funcitons #######################
 [a2sg_f1]
    type = ParsedFunction
    vals = a2sg1_area
    vars = area
    value = '-1e0/area'
  []
  [a2sg_f1c]
    type = ParsedFunction
    vals = a2sg1c_area
    vars = area
    value = '-1e0/area'
  []
   [a2sg_f2]
    type = ParsedFunction
    vals = a2sg2_area
    vars = area
    value = '-1e0/area'
  []
  [a2sg_f2c]
    type = ParsedFunction
    vals = a2sg2c_area
    vars = area
    value = '-1e0/area'
  []
   [a2sg_f3]
    type = ParsedFunction
    vals = a2sg3_area
    vars = area
    value = '-1e0/area'
  []
  [a2sg_f3c]
    type = ParsedFunction
    vals = a2sg3c_area
    vars = area
    value = '-1e0/area'
  []
   [a2sg_f4]
    type = ParsedFunction
    vals = a2sg4_area
    vars = area
    value = '-1e0/area'
  []
  [a2sg_f4c]
    type = ParsedFunction
    vals = a2sg4c_area
    vars = area
    value = '-1e0/area'
  []
  
  ############# a3 superglue funcitons #######################
 [a3sg_f1]
    type = ParsedFunction
    vals = a3sg1_area
    vars = area
    value = '-1e0/area'
  []
  [a3sg_f1c]
    type = ParsedFunction
    vals = a3sg1c_area
    vars = area
    value = '-1e0/area'
  []
   [a3sg_f2]
    type = ParsedFunction
    vals = a3sg2_area
    vars = area
    value = '-1e0/area'
  []
  [a3sg_f2c]
    type = ParsedFunction
    vals = a3sg2c_area
    vars = area
    value = '-1e0/area'
  []
   [a3sg_f3]
    type = ParsedFunction
    vals = a3sg3_area
    vars = area
    value = '-1e0/area'
  []
  [a3sg_f3c]
    type = ParsedFunction
    vals = a3sg3c_area
    vars = area
    value = '-1e0/area'
  []
   [a3sg_f4]
    type = ParsedFunction
    vals = a3sg4_area
    vars = area
    value = '-1e0/area'
  []
  [a3sg_f4c]
    type = ParsedFunction
    vals = a3sg4c_area
    vars = area
    value = '-1e0/area'
  []
[]

[BCs]
     [Pressure]
        [stress]
        boundary = 'a1_inner'
        function=rampLinear
        use_automatic_differentiation = true
        use_displaced_mesh = true
        hht_alpha=-.25
    []
            [stress2]
        boundary = 'a2_inner a3_inner'
        function=rampLinear2
        use_automatic_differentiation = true
        use_displaced_mesh = true
        hht_alpha=-.25
    []
    ############################### a1 superglue pressures  #################################
    	[sg1]
    	    	boundary='a1_support1'
    		function=sg_f1
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	[sg1c]
    	    	boundary='a1_support1h'
    		function=sg_f1c
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	    	[sg2]
    	    	boundary='a1_support2'
    		function=sg_f2
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	[sg2c]
    	    	boundary='a1_support2h'
    		function=sg_f2c
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	    	[sg3]
    	    	boundary='a1_support3'
    		function=sg_f3
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	[sg3c]
    	    	boundary='a1_support3h'
    		function=sg_f3c
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	    	[sg4]
    	    	boundary='a1_support4'
    		function=sg_f4
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	[sg4c]
    	    	boundary='a1_support4h'
    		function=sg_f4c
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	
        ############################### a2 superglue pressures  #################################
    	[a2sg1]
    	    	boundary='a2_support1'
    		function=a2sg_f1
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	[a2sg1c]
    	    	boundary='a2_support1h'
    		function=a2sg_f1c
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	    	[a2sg2]
    	    	boundary='a2_support2'
    		function=a2sg_f2
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	[a2sg2c]
    	    	boundary='a2_support2h'
    		function=a2sg_f2c
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	    	[a2sg3]
    	    	boundary='a2_support3'
    		function=a2sg_f3
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	[a2sg3c]
    	    	boundary='a2_support3h'
    		function=a2sg_f3c
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	    	[a2sg4]
    	    	boundary='a2_support4'
    		function=a2sg_f4
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	[a2sg4c]
    	    	boundary='a2_support4h'
    		function=a2sg_f4c
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	
    	    ############################### a3 superglue pressures  #################################
    	[a3sg1]
    	    	boundary='a3_support1'
    		function=a3sg_f1
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	[a3sg1c]
    	    	boundary='a3_support1h'
    		function=a3sg_f1c
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	    	[a3sg2]
    	    	boundary='a3_support2'
    		function=a3sg_f2
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	[a3sg2c]
    	    	boundary='a3_support2h'
    		function=a3sg_f2c
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	    	[a3sg3]
    	    	boundary='a3_support3'
    		function=a3sg_f3
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	[a3sg3c]
    	    	boundary='a3_support3h'
    		function=a3sg_f3c
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	    	[a3sg4]
    	    	boundary='a3_support4'
    		function=a3sg_f4
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    	[a3sg4c]
    	    	boundary='a3_support4h'
    		function=a3sg_f4c
    		hht_alpha = -.25
    		use_automatic_differentiation = true
    	[]
    []

  [hold_x]
    type =ADDirichletBC
    variable = disp_x
    boundary = 'base_top a1_base a2_base a3_base'
    value = 0.0
  []
  [hold_y]
    type = ADDirichletBC
    variable = disp_y
    boundary = 'base_top a1_base a2_base a3_base'
    value = 0.0
  []
  [hold_z]
    type = ADDirichletBC
    variable = disp_z
    boundary = 'base_top'
    value = 0.0
  []
  [lift_z]
  type=PresetDisplacement
  acceleration=accel_z
  beta=0.4
  boundary='a1_base a2_base a3_base'
  variable=disp_z
  velocity=vel_z
  function=top_motion
  []
[]

#[Dampers]
# [cs1]
# type=ContactSlipDamper
#
#     primary = 'item_contact_1'
#    secondary = 'a1_contact'
# []
# [cs2]
# type=ContactSlipDamper
#  damping_threshold_factor=10
#     primary = 'item_contact_4 '
#    secondary = 'a2_contact'
# []
# [cs3]
# type=ContactSlipDamper
#  damping_threshold_factor=10
#     primary = 'item_contact_4 '
#    secondary = 'a3_contact'
# []
#[]

[Contact]
  [b1]
    primary = 'a1_s1 a1_s2 a1_s3 a1_s4 a1_s5 a1_s6 a1_s7 a1_s8'
    secondary = 'a1_sh1 a1_sh2 a1_sh3 a1_sh4 a1_sh5 a1_sh6 a1_sh7 a1_sh8'
    model = frictionless
    penalty = 1e4 ################### this value needs to be inreased from .1e5, there is significant penetration at higher deformations. #########################
    formulation=penalty
    normalize_penalty=True
    normal_smoothing_distance = 0.1
    newmark_beta = 0.4
    newmark_gamma = 0.75
    []
    
     [b2]
    primary = 'a2_s1 a2_s2 a2_s3 a2_s4 a2_s5 a2_s6 a2_s7 a2_s8'
    secondary = 'a2_sh1 a2_sh2 a2_sh3 a2_sh4 a2_sh5 a2_sh6 a2_sh7 a2_sh8'
    model = frictionless
    penalty = 1e4 ################### this value needs to be inreased from .1e5, there is significant penetration at higher deformations. #########################
    formulation=penalty
    normalize_penalty=True
    normal_smoothing_distance = 0.1
    newmark_beta = 0.4
    newmark_gamma = 0.75
    []
    
      [b3]
    primary = 'a3_s1 a3_s2 a3_s3 a3_s4 a3_s5 a3_s6 a3_s7 a3_s8'
    secondary = 'a3_sh1 a3_sh2 a3_sh3 a3_sh4 a3_sh5 a3_sh6 a3_sh7 a3_sh8'
    model = frictionless
    penalty = 1e4 ################### this value needs to be inreased from .1e5, there is significant penetration at higher deformations. #########################
    formulation=penalty
    normalize_penalty=True
    normal_smoothing_distance = 0.1
    newmark_beta = 0.4
    newmark_gamma = 0.75
    []
   [superglue1]
    primary = 'a1_support1 a1_support2 a1_support3 a1_support4'
    secondary = 'a1_support1h a1_support2h a1_support3h a1_support4h'
    model = glued
    penalty = 2e5
    formulation=penalty
    normalize_penalty=True
    normal_smoothing_distance = 0.1
    newmark_beta = 0.4
    newmark_gamma = 0.75
    []
       [superglue2]
    primary = 'a2_support1 a2_support2 a2_support3 a2_support4'
    secondary = 'a2_support1h a2_support2h a2_support3h a2_support4h'
    model = glued
    penalty = 2e5
    formulation=penalty
    normalize_penalty=True
    normal_smoothing_distance = 0.1
    newmark_beta = 0.4
    newmark_gamma = 0.75
    []
       [superglue3]
    primary = 'a3_support1 a3_support2 a3_support3 a3_support4'
    secondary = 'a3_support1h a3_support2h a3_support3h a3_support4h'
    model = glued
    penalty = 2e5
    formulation=penalty
    normalize_penalty=True
    normal_smoothing_distance = 0.1
    newmark_beta = 0.4
    newmark_gamma = 0.75
    []
    
   [interesting_contact_1]
    primary = 'item_contact_1'
    secondary = 'a1_contact'
    model = glued
    friction_coefficient = 0.5
    penalty = 1e4 ################### this value needs to be inreased from .1e5, there is significant penetration at higher deformations. #########################
    formulation=penalty
    normalize_penalty=True
    normal_smoothing_distance = 0.1
    newmark_beta = 0.4
    newmark_gamma = 0.75
   []
      [interesting_contact_2]
    primary = 'item_contact_4 '
    secondary = 'a2_contact'
    model = coulomb
    friction_coefficient = 1000
    penalty = 1e4 ################### this value needs to be inreased from .1e5, there is significant penetration at higher deformations. #########################
    formulation=penalty
    normalize_penalty=True
    normal_smoothing_distance = 0.1
    newmark_beta = 0.4
    newmark_gamma = 0.75
   []
      [interesting_contact_3]
    primary = 'item_contact_4 '
    secondary = 'a3_contact'
    model = coulomb
    friction_coefficient = 1000
    penalty = 1e4 ################### this value needs to be inreased from .1e5, there is significant penetration at higher deformations. #########################
    formulation=penalty
    normalize_penalty=True
    normal_smoothing_distance = 0.1
    newmark_beta = 0.4
    newmark_gamma = 0.75
   []

         [support_1]
    primary = 'support2'
    secondary = 'base_top'
    model = frictionless
    penalty = 1e4 ################### this value needs to be inreased from .1e5, there is significant penetration at higher deformations. #########################
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
    mu=.1592e6  # compiled with proper NH formulaiton
    kappa=.1592e8
  []
    [./density1]
    type = GenericConstantMaterial
    prop_names = density
    prop_values = 1e-3
    block='base'
  [../]
  [./density2]
    type = GenericConstantMaterial
    prop_names = density
    prop_values = 1e-6
    block='a1h1 a1h2 a1h3 a1h4 a2h1 a2h2 a2h3 a2h3 a2h4 a3h1 a3h2 a3h3 a3h4 a1 a2 a3 item'
  [../]
[]

[Executioner]
  type = Transient
  solve_type=PJFNK
  nl_rel_tol = 1e-4
  nl_abs_tol =8e-4
  l_max_its = 5
  l_tol = 1e-7
  nl_max_its = 8

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
    type = ConstantDT
    dt=.005
    #type = IterationAdaptiveDT
    #growth_factor=1.2
    #cutback_factor=.8
    #optimal_iterations = 8
    #dt = .001
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
  
    	########################## a1 superglue #####################
  	[sg1_area]
	    type = AreaPostprocessor
    	    boundary = a1_support1
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[sg1c_area]
	    type = AreaPostprocessor
    	    boundary = a1_support1h
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	  	[sg2_area]
	    type = AreaPostprocessor
    	    boundary = a1_support2
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[sg2c_area]
	    type = AreaPostprocessor
    	    boundary = a1_support2h
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	  	[sg3_area]
	    type = AreaPostprocessor
    	    boundary = a1_support3
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[sg3c_area]
	    type = AreaPostprocessor
    	    boundary = a1_support3h
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	  	[sg4_area]
	    type = AreaPostprocessor
    	    boundary = a1_support4
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[sg4c_area]
	    type = AreaPostprocessor
    	    boundary = a1_support4h
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	
     	########################## a2 superglue #####################   	
    	[a2sg1_area]
	    type = AreaPostprocessor
    	    boundary = a2_support1
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[a2sg1c_area]
	    type = AreaPostprocessor
    	    boundary = a2_support1h
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[a2sg2_area]
	    type = AreaPostprocessor
    	    boundary = a2_support2
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[a2sg2c_area]
	    type = AreaPostprocessor
    	    boundary = a2_support2h
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	  	[a2sg3_area]
	    type = AreaPostprocessor
    	    boundary = a2_support3
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[a2sg3c_area]
	    type = AreaPostprocessor
    	    boundary = a2_support3h
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	  	[a2sg4_area]
	    type = AreaPostprocessor
    	    boundary = a2_support4
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[a2sg4c_area]
	    type = AreaPostprocessor
    	    boundary = a2_support4h
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	
    	########################## a3 superglue #####################
    	    	[a3sg1_area]
	    type = AreaPostprocessor
    	    boundary = a3_support1
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[a3sg1c_area]
	    type = AreaPostprocessor
    	    boundary = a3_support1h
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[a3sg2_area]
	    type = AreaPostprocessor
    	    boundary = a3_support2
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[a3sg2c_area]
	    type = AreaPostprocessor
    	    boundary = a3_support2h
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	  	[a3sg3_area]
	    type = AreaPostprocessor
    	    boundary = a3_support3
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[a3sg3c_area]
	    type = AreaPostprocessor
    	    boundary = a3_support3h
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	  	[a3sg4_area]
	    type = AreaPostprocessor
    	    boundary = a3_support4
    	    execute_on = 'INITIAL TIMESTEP_END'
    	    use_displaced_mesh=True
    	[]
    	[a3sg4c_area]
	    type = AreaPostprocessor
    	    boundary = a3_support4h
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
