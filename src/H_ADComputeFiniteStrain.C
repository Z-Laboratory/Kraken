//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "H_ADComputeFiniteStrain.h"
#include "RankTwoTensor.h"
#include "RankFourTensor.h"
#include "SymmetricRankTwoTensor.h"
#include "SymmetricRankFourTensor.h"

#include "libmesh/quadrature.h"
#include "libmesh/utility.h"

registerMooseObject("TensorMechanicsApp", H_ADComputeFiniteStrain);
registerMooseObject("TensorMechanicsApp", H_ADSymmetricFiniteStrain);

template <typename R2, typename R4>
MooseEnum
ADComputeFiniteStrainTemplH<R2, R4>::decompositionType()
{
  return MooseEnum("TaylorExpansion EigenSolution", "TaylorExpansion");
}

template <typename R2, typename R4>
InputParameters
ADComputeFiniteStrainTemplH<R2, R4>::validParams()
{
  InputParameters params = ADComputeIncrementalStrainBase::validParams();
  params.addClassDescription(
      "Compute a strain increment and rotation increment for finite strains.");
  params.addParam<MooseEnum>("decomposition_method",
                             ADComputeFiniteStrainTemplH<R2, R4>::decompositionType(),
                             "Methods to calculate the strain and rotation increments");
  return params;
}

template <typename R2, typename R4>
ADComputeFiniteStrainTemplH<R2, R4>::ADComputeFiniteStrainTemplH(const InputParameters & parameters)
  : ADComputeIncrementalStrainBaseTempl<R2>(parameters),
    _Fhat(this->_fe_problem.getMaxQps()),
    _F(this->template declareADProperty<ADR2>(_base_name + "F")),
    _B(this->template declareProperty<R2>(_base_name + "B")),
    _B_old(this->template getMaterialPropertyOldByName<R2>(_base_name + "B")),
    _F_total(this->template declareADProperty<ADR2>(_base_name + "F_total")),
    _decomposition_method(this->template getParam<MooseEnum>("decomposition_method").template getEnum<DecompMethod>())
{
}

template <typename R2, typename R4>
void
ADComputeFiniteStrainTemplH<R2, R4>::computeProperties()
{
  ADRankTwoTensor ave_Fhat;
  ADRankTwoTensor B;
  for (_qp = 0; _qp < _qrule->n_points(); ++_qp)
  {
    // Deformation gradient
    auto A = ADRankTwoTensor::initializeFromRows(
        (*_grad_disp[0])[_qp], (*_grad_disp[1])[_qp], (*_grad_disp[2])[_qp]);

    // Old Deformation gradient
    auto Fbar = ADRankTwoTensor::initializeFromRows(
        (*_grad_disp_old[0])[_qp], (*_grad_disp_old[1])[_qp], (*_grad_disp_old[2])[_qp]);
        
    Fbar.addIa(1.0);
    A.addIa(1.0);
    
    
    ADR2 X;
    X=ADR2(A);
    _F_total[_qp]=X;
    
        
    A -= Fbar;

    // Fbar = ( I + gradUold)
    //Fbar.addIa(1.0);

    // Incremental deformation gradient _Fhat = I + A Fbar^-1
    _Fhat[_qp] = A * Fbar.inverse();
    _Fhat[_qp].addIa(1.0);
    
    //ADR2 Q;
    //Q=ADR2(A);
    //Q.addIa(1.0);
    //_F[_qp]=ADR2(Q);
    _F[_qp]=ADR2(_Fhat[_qp]);


    // Calculate average _Fhat for volumetric locking correction
    if (_volumetric_locking_correction)
      ave_Fhat += _Fhat[_qp] * _JxW[_qp] * _coord[_qp];
  }

  if (_volumetric_locking_correction)
    ave_Fhat /= _current_elem_volume;

  const auto ave_Fhat_det = ave_Fhat.det();
  for (_qp = 0; _qp < _qrule->n_points(); ++_qp)
  {
    // Finalize volumetric locking correction
    if (_volumetric_locking_correction)
      _Fhat[_qp] *= std::cbrt(ave_Fhat_det / _Fhat[_qp].det());

   // computeQpStrain(); ############################################################### remove unneeded operations #############
  }
}

template <typename R2, typename R4>
void
ADComputeFiniteStrainTemplH<R2, R4>::computeQpStrain()
{
  ADR2 total_strain_increment;
  
  ADR2 B_inc;

  // two ways to calculate these increments: TaylorExpansion(default) or EigenSolution
  computeQpIncrements(total_strain_increment, _rotation_increment[_qp]);
  
  total_strain_increment.rotate(_rotation_increment[_qp]);
  
  B_inc=ADR2::timesTranspose(total_strain_increment);

  _strain_increment[_qp] = B_inc;

  //_strain_increment[_qp] = total_strain_increment;

  // Remove the eigenstrain increment
  this->subtractEigenstrainIncrementFromStrain(_strain_increment[_qp]);

  if (_dt > 0)
    _strain_rate[_qp] = _strain_increment[_qp] / _dt;
  else
    _strain_rate[_qp].zero();
    
    
  ADRankTwoTensor A;
  A=_strain_increment[_qp];
  ADRankTwoTensor B;
  B=_mechanical_strain_old[_qp];
  A *= B;
  ADR2 C;
  C=ADR2(A);

  // Update strain in intermediate configuration
  _mechanical_strain[_qp] = C;
  //_mechanical_strain[_qp].addIa(-1.0);
  _total_strain[_qp] = _total_strain_old[_qp] + total_strain_increment;
  
  //ADR2 M
  //ADR2 N;
  //M=ADR2(_strain_increment[_qp])
   
  //_B[_qp]=_strain_increment[_qp];
  //_B[_qp]*=N;
  
  //*ADR2(_B_old[_qp]);
   //_B= ADR2(*_B[_qp]);//*_B[_qp];
   
  //_total_strain[_qp] = _total_strain_old[_qp] + total_strain_increment;


  // Rotate strain to current configuration
  _mechanical_strain[_qp].rotate(_rotation_increment[_qp]);
  _total_strain[_qp].rotate(_rotation_increment[_qp]);

  if (_global_strain)
    _total_strain[_qp] += (*_global_strain)[_qp];
}

template <typename R2, typename R4>
void
ADComputeFiniteStrainTemplH<R2, R4>::computeQpIncrements(ADR2 & total_strain_increment,
                                                        ADRankTwoTensor & rotation_increment)
{
  switch (_decomposition_method)
  {
    case DecompMethod::TaylorExpansion:
    {  
      FADR2 Chat = ADR2::transposeTimes(_Fhat[_qp]);
      FADR2 Uhat = MathUtils::sqrt(Chat);
      
      
      //FADR2 Chat_total = ADR2::transposeTimes(_F_total[_qp]);
      //FADR2 Uhat_total = MathUtils::sqrt(Chat_total);
      
      rotation_increment = _Fhat[_qp] * Uhat.inverse().template get<ADRankTwoTensor>();
      //total_strain_increment = MathUtils::log(Uhat).template get<ADR2>();
      total_strain_increment = Uhat.template get<ADR2>();
      //total_strain_increment = ADR2::timesTranspose(_Fhat[_qp]);
      //total_strain_increment=Uhat;
      //total_strain_increment=ADRankTwoTensor(total_strain_increment);
      break;
    }

    case DecompMethod::EigenSolution:
    {
      FADR2 Chat = ADR2::transposeTimes(_Fhat[_qp]);
      FADR2 Uhat = MathUtils::sqrt(Chat);
      
      
      //FADR2 Chat_total = ADR2::transposeTimes(_F_total[_qp]);
      //FADR2 Uhat_total = MathUtils::sqrt(Chat_total);
      
      rotation_increment = _Fhat[_qp] * Uhat.inverse().template get<ADRankTwoTensor>();
      //total_strain_increment = MathUtils::log(Uhat).template get<ADR2>();
      total_strain_increment = Uhat.template get<ADR2>();
      //total_strain_increment = ADR2::timesTranspose(_Fhat[_qp]);
      //total_strain_increment=Uhat;
      //total_strain_increment=ADRankTwoTensor(total_strain_increment);
      break;
    }

    default:
      mooseError("ADComputeFiniteStrain Error: Pass valid decomposition type: TaylorExpansion or "
                 "EigenSolution.");
  }
}

template class ADComputeFiniteStrainTemplH<RankTwoTensor, RankFourTensor>;
template class ADComputeFiniteStrainTemplH<SymmetricRankTwoTensor, SymmetricRankFourTensor>;
