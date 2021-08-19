[Mesh]
    file='mesh/square_mesh.msh'
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


[Kernels]
  [./TensorMechanics]
    use_displaced_mesh = false
    use_automatic_differentiation = true
  [../]
[]


[Functions]
  [rampLinear]
    type = ParsedFunction
    value=-.25e6*t
  []
[]


[BCs]
    [Pressure]
        [stress1]
          boundary = 'my_back'
          function=rampLinear
          disp_x = disp_x
          disp_y = disp_y
          disp_z = disp_z
          use_automatic_differentiation=true
        []
        [stress2]
          boundary = 'my_left'
          function=rampLinear
          disp_x = disp_x
          disp_y = disp_y
          disp_z = disp_z
          use_automatic_differentiation=true
        []
    [] 


  [hold_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'my_right'
    value = 0.0
  []
    [hold_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'my_bottom'
    value = 0.0
  []
  [hold_z]
    type = DirichletBC
    variable = disp_z
    boundary = 'my_front'
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
  dtmin=.01
[]



[Postprocessors]
  [max]
  type=NodalExtremeValue
  variable=disp_x
  []
  [min]
  type=NodalExtremeValue
  variable=disp_y
  value_type=min
  []
[]

[Outputs]
  exodus = true
  perf_graph = true
[]
