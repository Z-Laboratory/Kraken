//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "Custom_ADComputeFiniteStrain_3.h"

#include "libmesh/quadrature.h"
#include "libmesh/utility.h"

registerMooseObject("TensorMechanicsApp", Custom_ADComputeFiniteStrain_3);

MooseEnum
Custom_ADComputeFiniteStrain_3::decompositionType()
{
  return MooseEnum("TaylorExpansion EigenSolution", "TaylorExpansion");
}

InputParameters
Custom_ADComputeFiniteStrain_3::validParams()
{
  InputParameters params = ADComputeIncrementalStrainBase::validParams();
  params.addClassDescription(
      "Compute a strain increment and rotation increment for finite strains.");
  params.addParam<MooseEnum>("decomposition_method",
                             Custom_ADComputeFiniteStrain_3::decompositionType(),
                             "Methods to calculate the strain and rotation increments");
  return params;
}

Custom_ADComputeFiniteStrain_3::Custom_ADComputeFiniteStrain_3(const InputParameters & parameters)
  : ADComputeIncrementalStrainBase(parameters),
    _Fhat(_fe_problem.getMaxQps()),
    _F(declareADProperty<RankTwoTensor>("F")),
    _decomposition_method(
        getParam<MooseEnum>("decomposition_method").template getEnum<DecompMethod>())
{
}



void
Custom_ADComputeFiniteStrain_3::computeProperties()
{
  ADRankTwoTensor ave_Fhat;
  ADRankTwoTensor I(ADRankTwoTensor::initIdentity);
  ADRankTwoTensor incremental_F;
  for (_qp = 0; _qp < _qrule->n_points(); ++_qp)
  {
    // Deformation gradient
    ADRankTwoTensor A((*_grad_disp[0])[_qp], (*_grad_disp[1])[_qp], (*_grad_disp[2])[_qp]);
    
    _F[_qp]=A+I;
    
    // Old Deformation gradient
    ADRankTwoTensor Fbar(
        (*_grad_disp_old[0])[_qp], (*_grad_disp_old[1])[_qp], (*_grad_disp_old[2])[_qp]);

    // A = gradU - gradUold
    A -= Fbar;
    incremental_F=A;

    // Fbar = ( I + gradUold)
    Fbar.addIa(1.0);

    // Incremental deformation gradient _Fhat = I + A Fbar^-1
    _Fhat[_qp] = A * Fbar.inverse();
    _Fhat[_qp].addIa(1.0);

    // Calculate average _Fhat for volumetric locking correction
    if (_volumetric_locking_correction)
      ave_Fhat += _Fhat[_qp] * _JxW[_qp] * _coord[_qp];
  }

  if (_volumetric_locking_correction)
    ave_Fhat /= _current_elem_volume;

  for (_qp = 0; _qp < _qrule->n_points(); ++_qp)
  {
    // Finalize volumetric locking correction
    if (_volumetric_locking_correction)
      // std::cbrt is not yet supported for dual numbers (MetaPhysicL/issues/36)
      _Fhat[_qp] *= std::pow(ave_Fhat.det() / _Fhat[_qp].det(), 1.0 / 3.0);

    computeQpStrain();
  }
}

void
Custom_ADComputeFiniteStrain_3::computeQpStrain()
{
  ADRankTwoTensor total_strain_increment;


  ADRankTwoTensor incremental_F;
  
      ADRankTwoTensor A((*_grad_disp[0])[_qp], (*_grad_disp[1])[_qp], (*_grad_disp[2])[_qp]);
    
    
    // Old Deformation gradient
    ADRankTwoTensor Fbar(
        (*_grad_disp_old[0])[_qp], (*_grad_disp_old[1])[_qp], (*_grad_disp_old[2])[_qp]);

    // A = gradU - gradUold
    A -= Fbar;
    incremental_F=A;
  // two ways to calculate these increments: TaylorExpansion(default) or EigenSolution
  computeQpIncrements(total_strain_increment, _rotation_increment[_qp]);

  _strain_increment[_qp] = incremental_F;

  // Remove the eigenstrain increment
  subtractEigenstrainIncrementFromStrain(_strain_increment[_qp]);

  if (_dt > 0)
    _strain_rate[_qp] = _strain_increment[_qp] / _dt;
  else
    _strain_rate[_qp].zero();

  // Update strain in intermediate configuration
  _mechanical_strain[_qp] = _mechanical_strain_old[_qp] + _strain_increment[_qp];
  _total_strain[_qp] = _total_strain_old[_qp] + total_strain_increment;

  // Rotate strain to current configuration
  _mechanical_strain[_qp] =
      _rotation_increment[_qp] * _mechanical_strain[_qp] * _rotation_increment[_qp].transpose();
  _total_strain[_qp] =
      _rotation_increment[_qp] * _total_strain[_qp] * _rotation_increment[_qp].transpose();

  if (_global_strain)
    _total_strain[_qp] += (*_global_strain)[_qp];
}

void
Custom_ADComputeFiniteStrain_3::computeQpIncrements(ADRankTwoTensor & total_strain_increment,
                                           ADRankTwoTensor & rotation_increment)
{
  switch (_decomposition_method)
  {
    case DecompMethod::TaylorExpansion:
    {
      // inverse of _Fhat
      const ADRankTwoTensor invFhat = _Fhat[_qp].inverse();

      // A = I - _Fhat^-1
      ADRankTwoTensor A(ADRankTwoTensor::initIdentity);
      A -= invFhat;

      // Cinv - I = A A^T - A - A^T;
      ADRankTwoTensor Cinv_I = A * A.transpose() - A - A.transpose();
      
      ADRankTwoTensor I(ADRankTwoTensor::initIdentity);
      ADRankTwoTensor C=Cinv_I+I;
      C=C.inverse();
      total_strain_increment=C;
      

      // strain rate D from Taylor expansion, Chat = (-1/2(Chat^-1 - I) + 1/4*(Chat^-1 - I)^2 + ...
      //total_strain_increment = -Cinv_I * 0.5 + Cinv_I * Cinv_I * 0.25;
      
      
      //my attempts
      //ADRankTwoTensor I(ADRankTwoTensor::initIdentity);
      //total_strain_increment=Cinv_I;
      //total_strain_increment=_Fhat[_qp]*_Fhat[_qp].transpose();

      const ADReal a[3] = {invFhat(1, 2) - invFhat(2, 1),
                           invFhat(2, 0) - invFhat(0, 2),
                           invFhat(0, 1) - invFhat(1, 0)};

      const auto q = (a[0] * a[0] + a[1] * a[1] + a[2] * a[2]) / 4.0;
      const auto trFhatinv_1 = invFhat.trace() - 1.0;
      const auto p = trFhatinv_1 * trFhatinv_1 / 4.0;

      // cos theta_a
      const ADReal C1_squared =
          p + 3.0 * Utility::pow<2>(p) * (1.0 - (p + q)) / Utility::pow<2>(p + q) -
          2.0 * Utility::pow<3>(p) * (1.0 - (p + q)) / Utility::pow<3>(p + q);
      mooseAssert(C1_squared >= 0.0,
                  "Cannot take square root of a negative number. This may happen when elements "
                  "become heavily distorted.");
      const ADReal C1 = std::sqrt(C1_squared);

      ADReal C2;
      if (q > 0.01)
        // (1-cos theta_a)/4q
        C2 = (1.0 - C1) / (4.0 * q);
      else
        // alternate form for small q
        C2 = 0.125 + q * 0.03125 * (Utility::pow<2>(p) - 12.0 * (p - 1.0)) / Utility::pow<2>(p) +
             Utility::pow<2>(q) * (p - 2.0) * (Utility::pow<2>(p) - 10.0 * p + 32.0) /
                 Utility::pow<3>(p) +
             Utility::pow<3>(q) *
                 (1104.0 - 992.0 * p + 376.0 * Utility::pow<2>(p) - 72.0 * Utility::pow<3>(p) +
                  5.0 * Utility::pow<4>(p)) /
                 (512.0 * Utility::pow<4>(p));

      const ADReal C3_test =
          (p * q * (3.0 - q) + Utility::pow<3>(p) + Utility::pow<2>(q)) / Utility::pow<3>(p + q);
      mooseAssert(C3_test >= 0.0,
                  "Cannot take square root of a negative number. This may happen when elements "
                  "become heavily distorted.");
      const ADReal C3 = 0.5 * std::sqrt(C3_test); // sin theta_a/(2 sqrt(q))

      // Calculate incremental rotation. Note that this value is the transpose of that from Rashid,
      // 93, so we transpose it before storing
      ADRankTwoTensor R_incr;
      R_incr.addIa(C1);
      for (unsigned int i = 0; i < 3; ++i)
        for (unsigned int j = 0; j < 3; ++j)
          R_incr(i, j) += C2 * a[i] * a[j];

      R_incr(0, 1) += C3 * a[2];
      R_incr(0, 2) -= C3 * a[1];
      R_incr(1, 0) -= C3 * a[2];
      R_incr(1, 2) += C3 * a[0];
      R_incr(2, 0) += C3 * a[1];
      R_incr(2, 1) -= C3 * a[0];

      rotation_increment = R_incr.transpose();
      break;
    }

    case DecompMethod::EigenSolution:
    {
      std::vector<ADReal> e_value(3);
      ADRankTwoTensor e_vector, N1, N2, N3;

      const auto Chat = _Fhat[_qp].transpose() * _Fhat[_qp];
      Chat.symmetricEigenvaluesEigenvectors(e_value, e_vector);

      const auto lambda1 = std::sqrt(e_value[0]);
      const auto lambda2 = std::sqrt(e_value[1]);
      const auto lambda3 = std::sqrt(e_value[2]);

      N1.vectorOuterProduct(e_vector.column(0), e_vector.column(0));
      N2.vectorOuterProduct(e_vector.column(1), e_vector.column(1));
      N3.vectorOuterProduct(e_vector.column(2), e_vector.column(2));

      const auto Uhat = N1 * lambda1 + N2 * lambda2 + N3 * lambda3;
      const ADRankTwoTensor invUhat(Uhat.inverse());

      rotation_increment = _Fhat[_qp] * invUhat;

      total_strain_increment =
          N1 * std::log(lambda1) + N2 * std::log(lambda2) + N3 * std::log(lambda3);
      break;
    }

    default:
      mooseError("Custom_ADComputeFiniteStrain_3 Error: Pass valid decomposition type: TaylorExpansion or "
                 "EigenSolution.");
  }
}
