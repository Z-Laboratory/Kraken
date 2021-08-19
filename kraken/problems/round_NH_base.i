[Mesh]
    file='mesh/finger_v5_big.msh'
    #file='mesh/3_cavity'
    dim=3
    use_displaced_mesh = true
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

[Kernels]
  [./TensorMechanics]
    use_displaced_mesh = true
    use_automatic_differentiation = true
  [../]
[]


[Functions]
  [./rampLinear]
    type = ParsedFunction
    value=.0822e6*t/2
  []
[]

[AuxVariables]
  [./vonmises]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./strain_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]



[BCs]
    [Pressure]

            [stress2]
        boundary = 'entry'
        function=rampLinear
        disp_x = disp_x
        disp_y = disp_y
        disp_z = disp_z
    []
            [stress3]
        boundary = 'top_inner'
        function=rampLinear
        disp_x = disp_x
        disp_y = disp_y
        disp_z = disp_z
    []
            [stress4]
        boundary = 'bottom_inner'
        function=rampLinear
        disp_x = disp_x
        disp_y = disp_y
        disp_z = disp_z
    []
    [] 
    
  [hold_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'front'
    value = 0.0
  []
    [hold_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'front'
    value = 0.0
  []
  [hold_z]
    type = DirichletBC
    variable = disp_z
    boundary = 'front'
    value = 0.0
  []

[]

[Materials]
  [strain]
    type = Custom_ADComputeFiniteStrain
    displacements = 'disp_x disp_y disp_z'
  []
  [elasitc_stress]
    type=AD_NH_V3
    #type=Compressable_neo_hookean
    mu=.2069e6
    kappa=.2069e8
    large_rotations=False

  []

[]

[Executioner]

  [TimeIntegrator]
    type=Heun
  []

  type = Transient
  solve_type=PJFNK
  nl_rel_tol = 2e-3
  nl_abs_tol =2e-3
  l_max_its = 20
  l_tol = 1e-4
  nl_max_its = 20
  
  petsc_options_iname = '-pc_type -pc_hypre_type -pc_hypre_boomeramg_strong_threshold'
  petsc_options_value = 'hypre boomeramg .5'
  
  #petsc_options = '-snes_ksp_ew'
  #petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap -ksp_gmres_restart'
  #petsc_options_value = 'asm lu 20 151'
  
  automatic_scaling=true
  compute_scaling_once=false
  
  start_time=0.0
  end_time=10
  [TimeStepper]
    #Iteration adaptive
    type = IterationAdaptiveDT
    optimal_iterations = 5
    dt = .1
    cutback_factor=.5
    growth_factor=1.2
  []
  dtmin=.1
[]



[Postprocessors]
  [max]
  type=NodalExtremeValue
  variable=disp_y
  []
  [min]
  type=NodalExtremeValue
  variable=disp_x
  value_type=min
  []
[]

[Outputs]
  exodus = true
  [pgraph]
    type = PerfGraphOutput
    execute_on = TIMESTEP_END 
  []
[]
