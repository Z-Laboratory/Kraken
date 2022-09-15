//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ADComputeStressBase.h"
#include "GuaranteeConsumer.h"

/**
 * ADComputeFiniteStrainElasticStress computes the stress following elasticity
 * theory for finite strains
 */
template <typename R2, typename R4>
class ADComputeFiniteStrainElasticStressTemplH2 : public ADComputeStressBaseTempl<R2>,
                                                public GuaranteeConsumer
{
public:
  static InputParameters validParams();

  ADComputeFiniteStrainElasticStressTemplH2(const InputParameters & parameters);

  void initialSetup() override;
  virtual void initQpStatefulProperties() override;

protected:
  using ADR2 = Moose::GenericType<R2, true>;
  using ADR4 = Moose::GenericType<R4, true>;
  using FADR2 = FactorizedRankTwoTensorTempl<ADR2>;

  virtual void computeQpStress() override;

  /// Name of the elasticity tensor material property
  const std::string _elasticity_tensor_name;
  /// Elasticity tensor material property
  const ADMaterialProperty<R4> & _elasticity_tensor;
  const ADMaterialProperty<R2> & _strain_increment;
  /// Rotation up to current step "n" to compute anisotropic elasticity tensor
  ADMaterialProperty<RankTwoTensor> & _rotation_total;
  /// Rotation up to "n - 1" (previous) step to compute anisotropic elasticity tensor
  const MaterialProperty<RankTwoTensor> & _rotation_total_old;

  const ADMaterialProperty<RankTwoTensor> & _rotation_increment;
  
  const ADMaterialProperty<ADR2> & _F;
  const ADMaterialProperty<ADR2> & _F_total;
  
 

  const Real & _mu;
  const Real & _kappa;

  /// The old stress tensor
  const MaterialProperty<R2> & _stress_old;
  
 // const ADMaterialProperty<ADR2> & _B_old;
 //  const ADMaterialProperty<ADR2> & _B;

  /**
   * The old elastic strain is used to calculate the old stress in the case
   * of variable elasticity tensors
   */
  const MaterialProperty<R2> & _elastic_strain_old;

  usingComputeStressBaseMembers;
};

typedef ADComputeFiniteStrainElasticStressTemplH2<RankTwoTensor, RankFourTensor>
    H2_ADComputeFiniteStrainElasticStress;
typedef ADComputeFiniteStrainElasticStressTemplH2<SymmetricRankTwoTensor, SymmetricRankFourTensor>
    H2_ADSymmetricFiniteStrainElasticStress;
