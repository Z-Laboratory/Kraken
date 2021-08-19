//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "Custom_ADComputeGreenLagrangeStrain.h"
#include "libmesh/quadrature.h"

registerMooseObject("KrakenApp", Custom_ADComputeGreenLagrangeStrain);

InputParameters
Custom_ADComputeGreenLagrangeStrain::validParams()
{
  InputParameters params = ADComputeStrainBase::validParams();
  params.addClassDescription("Compute a Green-Lagrange strain.");
  return params;
}

Custom_ADComputeGreenLagrangeStrain::Custom_ADComputeGreenLagrangeStrain(const InputParameters & parameters)
  : ADComputeStrainBase(parameters),
  _F(declareADProperty<RankTwoTensor>("F"))
{
  // error out if unsupported features are to be used
  if (_global_strain)
    paramError("global_strain",
               "Global strain (periodicity) is not yet supported for Green-Lagrange strains");
  if (!_eigenstrains.empty())
    paramError("eigenstrain_names",
               "Eigenstrains are not yet supported for Green-Lagrange strains");
  if (_volumetric_locking_correction)
    paramError("volumetric_locking_correction",
               "Volumetric locking correction is not implemented for Green-Lagrange strains");
}

void
Custom_ADComputeGreenLagrangeStrain::initQpStatefulProperties()
{
  _F[_qp].zero();
}

void
Custom_ADComputeGreenLagrangeStrain::computeProperties()
{
  ADRankTwoTensor I(ADRankTwoTensor::initIdentity);
  for (_qp = 0; _qp < _qrule->n_points(); ++_qp)
  {
    ADRankTwoTensor dxu((*_grad_disp[0])[_qp], (*_grad_disp[1])[_qp], (*_grad_disp[2])[_qp]);
    ADRankTwoTensor dxuT = dxu.transpose();

    /// extra additions
    _F[_qp]=dxu;
    _F[_qp]+=I;
    ADRankTwoTensor C=_F[_qp]*_F[_qp].transpose();
    ADRankTwoTensor E=(C-I)/2;
   //_mechanical_strain[_qp] = _total_strain[_qp] = E;

    /// change definition of external variables
    ///_mechanical_strain[_qp] = _total_strain[_qp] = (dxuT + dxu + dxuT * dxu) / 2.0;
  }
}
