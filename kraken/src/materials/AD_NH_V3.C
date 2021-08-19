//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "AD_NH_V3.h"

registerMooseObject("TensorMechanicsApp", AD_NH_V3);

InputParameters
AD_NH_V3::validParams()
{
  InputParameters params = ADComputeStressBase::validParams();
  params.addClassDescription("Compute stress using elasticity for finite strains");
  
  params.addRequiredParam<double>("mu", "shear modulus");
  params.addRequiredParam<double>("kappa", "bulk modulus");
  params.addRequiredParam<bool>("large_rotations", "whether or not to use rotational increments");
  return params;
}

AD_NH_V3::AD_NH_V3(
    const InputParameters & parameters)
  : ADComputeStressBase(parameters),
  _F(getADMaterialProperty<RankTwoTensor>("F")),
  _mu(getParam<double>("mu")),
  _kappa(getParam<double>("kappa")),
  _large_rotations(getParam<bool>("large_rotations")),
  
    GuaranteeConsumer(this),
    _strain_increment(getADMaterialPropertyByName<RankTwoTensor>(_base_name + "strain_increment")),
    _rotation_total(declareADProperty<RankTwoTensor>("rotation_total")),
    _rotation_total_old(getMaterialPropertyOldByName<RankTwoTensor>("rotation_total")),
    _rotation_increment(
        getADMaterialPropertyByName<RankTwoTensor>(_base_name + "rotation_increment")),
    _stress_old(getMaterialPropertyOldByName<RankTwoTensor>(_base_name + "stress")),
    _elastic_strain_old(getMaterialPropertyOldByName<RankTwoTensor>(_base_name + "elastic_strain"))
{
}

void
AD_NH_V3::initialSetup()
{
}

void
AD_NH_V3::initQpStatefulProperties()
{
  ADComputeStressBase::initQpStatefulProperties();
  RankTwoTensor identity_rotation(RankTwoTensor::initIdentity);

  _rotation_total[_qp] = identity_rotation;
}

void
AD_NH_V3::computeQpStress()
{
  // Calculate the stress in the intermediate configuration
  ADRankTwoTensor intermediate_stress;
  ADRankTwoTensor I(ADRankTwoTensor::initIdentity);

  for (_qp = 0; _qp < _qrule->n_points(); ++_qp)
  {
    ADRankTwoTensor B=_F[_qp].transpose()*_F[_qp];
    double J=_F[_qp].det().value();
    double C1=_mu/2;
    double D1=_kappa/2;

    double p=2*D1*(J-1);
    intermediate_stress=2*C1*B+p*I;

  
    // Rotate the stress state to the current configuration
    if  (_large_rotations){
    _stress[_qp] = _rotation_increment[_qp] * intermediate_stress * _rotation_increment[_qp].transpose();
    }
    else{_stress[_qp] = _rotation_total[_qp] * intermediate_stress * _rotation_total[_qp].transpose(); 
    }


    // Assign value for elastic strain, which is equal to the mechanical strain
    _elastic_strain[_qp] = _mechanical_strain[_qp];
    }
}
