[Mesh]
    file='mesh/10_1aspect.msh'
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
    use_displaced_mesh = true
    #use_displaced_mesh = false
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
        [stress]
        boundary = 'my_top'
        function=rampLinear
        disp_x = disp_x
        disp_y = disp_y
        disp_z = disp_z
        use_automatic_differentiation = true
        use_displaced_mesh = true
        #use_displaced_mesh = false
    []
    [] 

  [hold_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'side2'
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
    boundary = 'side1'
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
  type = Transient
  solve_type=PJFNK
  nl_rel_tol = 1e-4
  nl_abs_tol =1e-4
  l_max_its = 20
  l_tol = 1e-4
  nl_max_its = 10
  petsc_options_iname = '-pc_type -pc_hypre_type '
  petsc_options_value = 'hypre boomeramg'
  automatic_scaling=true
  compute_scaling_once=false
  start_time=0.0
  end_time=30
  [TimeStepper]
    type = ConstantDT
    dt=.1
  []
  [TimeIntegrator]
  	type=ImplicitEuler
  	#this is the default
  []
  dtmin=.01
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
[]

[Outputs]
  exodus = true
  [pgraph]
    type = PerfGraphOutput
    execute_on = TIMESTEP_END 
  []
[]
