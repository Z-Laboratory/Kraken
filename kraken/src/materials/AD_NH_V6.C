//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "AD_NH_V6.h"

registerMooseObject("TensorMechanicsApp", AD_NH_V6);

InputParameters
AD_NH_V6::validParams()
{
  InputParameters params = ADComputeStressBase::validParams();
  params.addClassDescription("Compute stress using elasticity for finite strains");
  
  params.addRequiredParam<double>("mu", "shear modulus");
  params.addRequiredParam<double>("kappa", "bulk modulus");
  return params;
}

AD_NH_V6::AD_NH_V6(
    const InputParameters & parameters)
  : ADComputeStressBase(parameters),
  _F(getADMaterialProperty<RankTwoTensor>("F")),
  _mu(getParam<double>("mu")),
  _kappa(getParam<double>("kappa")),
  
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
AD_NH_V6::initialSetup()
{
}

void
AD_NH_V6::initQpStatefulProperties()
{
  ADComputeStressBase::initQpStatefulProperties();
  RankTwoTensor identity_rotation(RankTwoTensor::initIdentity);

  _rotation_total[_qp] = identity_rotation;
}

void
AD_NH_V6::computeQpStress()
{
  // Calculate the stress in the intermediate configuration
  ADRankTwoTensor intermediate_stress;
  ADRankTwoTensor I(ADRankTwoTensor::initIdentity);
  ADRankTwoTensor F2;

  for (_qp = 0; _qp < _qrule->n_points(); ++_qp)
  {
    
    //F2=_rotation_increment[_qp] * _F[_qp] * _rotation_increment[_qp].transpose();
    
    //ADRankTwoTensor B=F2.transpose()*F2;
    //double J =F2.det().value();
    
    //ADRankTwoTensor C=_F[_qp]*_F[_qp].transpose();
    ADRankTwoTensor B=_F[_qp].transpose()*_F[_qp];
    
    //B=_rotation_increment[_qp] * B * _rotation_increment[_qp].transpose();
    
    //ADRankTwoTensor B=(_elastic_strain_old[_qp]+_strain_increment[_qp])+I;
    double J=_F[_qp].det().value();
    //double J=B.det().value();
    //J=pow(J,1/2);
    double C1=_mu/2;
    double D1=_kappa/2;
    //double I1=C.trace().value();


    // Rotate elasticity tensor to the intermediate configuration
    // That is, elasticity tensor is defined in the previous time step
    // This is consistent with the definition of strain increment
    // The stress is projected onto the current configuration a few lines below
    //ADRankFourTensor elasticity_tensor_rotated = _elasticity_tensor[_qp];
    //elasticity_tensor_rotated.rotate(_rotation_total_old[_qp]);

  
    //trial 1
    //best implementation
    double p=2*D1*(1-J);
    intermediate_stress=2*C1*B-p*I;
    


    // Update current total rotation matrix to be used in next step
    // not actually used with isotropic material
    //_rotation_total[_qp] = _rotation_increment[_qp] * _rotation_total_old[_qp];
  
    // Rotate the stress state to the current configuration
    _stress[_qp] =
      _rotation_increment[_qp] * intermediate_stress * _rotation_increment[_qp].transpose();

    // Assign value for elastic strain, which is equal to the mechanical strain
    _elastic_strain[_qp] = _mechanical_strain[_qp];
    }
}
