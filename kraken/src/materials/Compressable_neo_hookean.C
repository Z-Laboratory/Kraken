//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "Compressable_neo_hookean.h"
#include "libmesh/quadrature.h"
#include "Custom_ADComputeGreenLagrangeStrain.h"

registerMooseObject("KrakenApp", Compressable_neo_hookean);

InputParameters
Compressable_neo_hookean::validParams()
{
  InputParameters params = ADComputeStressBase::validParams();
  params.addClassDescription("Compute stress using elasticity for small strains");

  params.addRequiredParam<double>("mu", "shear modulus");
  params.addRequiredParam<double>("kappa", "bulk modulus");
  params.addRequiredParam<bool>("compressable", "which equation to use");

  return params;
}

Compressable_neo_hookean::Compressable_neo_hookean(const InputParameters & parameters)
  : ADComputeStressBase(parameters),
  _F(getADMaterialProperty<RankTwoTensor>("F")),
  _mu(getParam<double>("mu")),
  _kappa(getParam<double>("kappa")),
  _compressable(getParam<bool>("compressable"))
    //_grad_disp(3),    
    //_mechanical_strain(declareADProperty<RankTwoTensor>(_base_name + "mechanical_strain")),
    //_total_strain(declareADProperty<RankTwoTensor>(_base_name + "total_strain")),
    ///_elasticity_tensor_name(_base_name + "elasticity_tensor"),
    ///_elasticity_tensor(getADMaterialProperty<RankFourTensor>(_elasticity_tensor_name))
{
}

void
Compressable_neo_hookean::initialSetup()
{
}

void
Compressable_neo_hookean::computeQpStress()
{
  ADRankTwoTensor I(ADRankTwoTensor::initIdentity);

  for (_qp = 0; _qp < _qrule->n_points(); ++_qp)
  {
    
    ADRankTwoTensor C=_F[_qp]*_F[_qp].transpose();
    ADRankTwoTensor B=_F[_qp].transpose()*_F[_qp];
    double J=_F[_qp].det().value();
    double C1=_mu/2;
    double D1=_kappa/2;
    double I1=C.trace().value();

   // as _kappa increases, we better model incompressability, but computation time increases dramatically

    // implement compressable neo-hookean equations

    // this converges! we had to switch to doubles, not dual numbers and invert D1
    
    // this is what is the proper equation
    //_stress[_qp] =((2*D1*J*(J-1))*I+2*(C1/(pow(J,2/3)))*(B-I1/3*I))/J;

    // this is what was tested
    //_stress[_qp] =((2*D1*J*(J-1))*I+2*C1*I+2*(C1/(pow(J,2/3)))*(C-I1/3*I))/J;
    
    //performance notes:
    // 10% below theoretical incompressable deformation w/ _kappa =1e8
    // this could be in large part due to werid effects from boundry conditions
    
    // 8 seconds for uniaxial extension with _kappa=1e8
    // 33 seconds for uniaxial extension with _kappa=1e9
    // won't converge for uniaxial extension with _kappa=1e10


    
    //incompressable
    double p=2*(J-1)*D1;

    if (_compressable){
      _stress[_qp] =((2*D1*J*(J-1))*I+2*(C1/(pow(J,2/3)))*(B-I1/3*I))/J;
    }
    else{
       _stress[_qp] =p*I+ 2*C1*B;
    }
    
    
    // Assign value for elastic strain, which is equal to the mechanical strain
    _elastic_strain[_qp] = _mechanical_strain[_qp];
  }
}
