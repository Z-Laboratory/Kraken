//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "Custom_ADComputeFiniteStrainElasticStress_2.h"

registerMooseObject("TensorMechanicsApp", Custom_ADComputeFiniteStrainElasticStress_2);

InputParameters
Custom_ADComputeFiniteStrainElasticStress_2::validParams()
{
  InputParameters params = ADComputeStressBase::validParams();
  params.addClassDescription("Compute stress using elasticity for finite strains");
  params.addRequiredParam<double>("mu", "shear modulus");
  params.addRequiredParam<double>("kappa", "incompressibility factor");
  return params;
}

Custom_ADComputeFiniteStrainElasticStress_2::Custom_ADComputeFiniteStrainElasticStress_2(
    const InputParameters & parameters)
  : ADComputeStressBase(parameters),
    GuaranteeConsumer(this),
    _elasticity_tensor_name(_base_name + "elasticity_tensor"),
    _elasticity_tensor(getADMaterialProperty<RankFourTensor>(_elasticity_tensor_name)),
    _strain_increment(getADMaterialPropertyByName<RankTwoTensor>(_base_name + "strain_increment")),
    _mu(getParam<double>("mu")),
    _kappa(getParam<double>("kappa")),
    _rotation_total(declareADProperty<RankTwoTensor>("rotation_total")),
    _rotation_total_old(getMaterialPropertyOldByName<RankTwoTensor>("rotation_total")),
    _rotation_increment(
        getADMaterialPropertyByName<RankTwoTensor>(_base_name + "rotation_increment")),
    _stress_old(getMaterialPropertyOldByName<RankTwoTensor>(_base_name + "stress")),
    _elastic_strain_old(getMaterialPropertyOldByName<RankTwoTensor>(_base_name + "elastic_strain"))
{
}

void
Custom_ADComputeFiniteStrainElasticStress_2::initialSetup()
{
}

void
Custom_ADComputeFiniteStrainElasticStress_2::initQpStatefulProperties()
{
  ADComputeStressBase::initQpStatefulProperties();
  RankTwoTensor identity_rotation(RankTwoTensor::initIdentity);

  _rotation_total[_qp] = identity_rotation;
}

void
Custom_ADComputeFiniteStrainElasticStress_2::computeQpStress()
{
  // Calculate the stress in the intermediate configuration
  ADRankTwoTensor I(ADRankTwoTensor::initIdentity);
  ADRankTwoTensor intermediate_stress;
  ADRankTwoTensor strain;
  ADRankTwoTensor F;
  ADRankTwoTensor B;
  //ADRankTwoTensor strain_v2;
  //double J;
  
  strain=(_strain_increment[_qp] + _elastic_strain_old[_qp]);
  F=strain+I;
  B=F*F.transpose();
  //strain_v2=strain*strain.transpose();
  //J= F.det().value();
  intermediate_stress = _mu *B;
  // +2*_kappa*(J-1)*I;
  
  // Rotate the stress state to the current configuration
  _stress[_qp] =
      _rotation_increment[_qp] * intermediate_stress * _rotation_increment[_qp].transpose();

  // Assign value for elastic strain, which is equal to the mechanical strain
  _elastic_strain[_qp] = _mechanical_strain[_qp];
}
