//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "H_ADComputeFiniteStrainElasticStress.h"
#include "RankTwoTensor.h"
#include "RankFourTensor.h"
#include "SymmetricRankTwoTensor.h"
#include "SymmetricRankFourTensor.h"

#include "H_ADComputeFiniteStrain.h"
#include "RankTwoTensor.h"
#include "RankFourTensor.h"
#include "SymmetricRankTwoTensor.h"
#include "SymmetricRankFourTensor.h"

#include "libmesh/quadrature.h"
#include "libmesh/utility.h"

registerMooseObject("TensorMechanicsApp", H_ADComputeFiniteStrainElasticStress);
registerMooseObject("TensorMechanicsApp", H_ADSymmetricFiniteStrainElasticStress);

template <typename R2, typename R4>
InputParameters
ADComputeFiniteStrainElasticStressTemplH<R2, R4>::validParams()
{
  InputParameters params = ADComputeStressBase::validParams();
  params.addClassDescription("Compute stress using elasticity for finite strains");
  params.addRequiredParam<Real>("mu", "value of mu");
  params.addRequiredParam<Real>("kappa", "value of kappa");
  params.addRequiredParam<bool>("large_rotations", "whether or not to use rotational increments");
  return params;
}

template <typename R2, typename R4>
ADComputeFiniteStrainElasticStressTemplH<R2, R4>::ADComputeFiniteStrainElasticStressTemplH(
    const InputParameters & parameters)
  : ADComputeStressBaseTempl<R2>(parameters),
    _mu(this->template getParam<Real>("mu")),
    _kappa(this->template getParam<Real>("kappa")),
    _large_rotations(this->template getParam<bool>("large_rotations")),
    GuaranteeConsumer(this),
    //_elasticity_tensor_name(_base_name + "elasticity_tensor"),
    //_elasticity_tensor(this->template getADMaterialProperty<R4>(_elasticity_tensor_name)),
    _strain_increment(
        this->template getADMaterialPropertyByName<R2>(_base_name + "strain_increment")),
    _rotation_total(this->template declareADProperty<RankTwoTensor>(_base_name + "rotation_total")),
    _rotation_total_old(
        this->template getMaterialPropertyOldByName<RankTwoTensor>(_base_name + "rotation_total")),
    _rotation_increment(this->template getADMaterialPropertyByName<RankTwoTensor>(
        _base_name + "rotation_increment")),
        
    _F(this->template getADMaterialPropertyByName<ADR2>(_base_name + "F")),
    _F_total(this->template getADMaterialPropertyByName<ADR2>(_base_name + "F_total")),
    _stress_old(this->template getMaterialPropertyOldByName<R2>(_base_name + "stress")),
    //_B_old(this->template getMaterialPropertyOldByName<R2>(_base_name + "B")),
    //_B(this->template getADMaterialPropertyByName<R2>(_base_name + "B")),
    _elastic_strain_old(
        this->template getMaterialPropertyOldByName<R2>(_base_name + "elastic_strain"))
    
{
}

template <typename R2, typename R4>
void
ADComputeFiniteStrainElasticStressTemplH<R2, R4>::initialSetup()
{
}

template <typename R2, typename R4>
void
ADComputeFiniteStrainElasticStressTemplH<R2, R4>::initQpStatefulProperties()
{
  ADComputeStressBaseTempl<R2>::initQpStatefulProperties();
  _rotation_total[_qp] = RankTwoTensor::Identity();
}

template <typename R2, typename R4>
void
ADComputeFiniteStrainElasticStressTemplH<R2, R4>::computeQpStress()
{
  // Calculate the stress in the intermediate configuration
  ADR2 intermediate_stress;
  
  ADR2 NH;
  

  
  
  //ADR2 B_hat=ADR2::timesTranspose(_F[_qp]);
  // B_hat.rotate(_rotation_increment[_qp]);
  
  //NH=_mu*B_hat-I*_kappa*(1-_F[_qp].det());
  
  //implementation with C
  /*
  ADR2 C_hat=ADR2::transposeTimes(_F[_qp]);
  ADR2 I(ADR2::initIdentity);
  NH=_mu*C_hat-I*_kappa*(1-_F[_qp].det());
  NH.rotate(_rotation_increment[_qp]);
  _stress[_qp]=NH;
  */



  //implementation with B
  /*
  ADRankTwoTensor A;
  A=_strain_increment[_qp];
  ADRankTwoTensor B;
  B=_elastic_strain_old[_qp];
  A *= B;
  ADR2 C;
  C=ADR2(A);
  */
  
  ADR2 F_tmp=_F_total[_qp];
  //F_tmp.rotate(_rotation_increment[_qp]);
  ADR2 B_inc=ADR2::timesTranspose(F_tmp);
  //B_hat.rotate(_rotation_increment[_qp]);
  
  //_B[_qp]=F_tmp*_B_old[_qp];
 
 
   /*
   const Real E=.01; 
   RankTwoTensor D;
   D=_rotation_total_old[_qp];
   D*=E;
   D.addIa((1.0-E));
  _rotation_total[_qp] = _rotation_increment[_qp] * D;
  */
  ADR2 I(ADR2::initIdentity);
  //I.rotate(_rotation_total[_qp]);
  NH=_mu*B_inc-I*_kappa*(1-_F_total[_qp].det());
  //NH.rotate(_rotation_increment);
  //_stress[_qp]=NH;
  
  
  /*
  FADR2 Chat = ADR2::transposeTimes(F_tmp);
  FADR2 Uhat = MathUtils::sqrt(Chat);
  ADRankTwoTensor Z;
  ADRankTwoTensor Q;
  Q=F_tmp;
  Z = Q * Uhat.inverse().template get<ADRankTwoTensor>();
  ADRankTwoTensor MNM(ADRankTwoTensor::initIdentity);
  */
  

  
  _stress[_qp]=NH;
  if  (_large_rotations){
    ADRankTwoTensor A1=.5*(F_tmp+F_tmp.inverse().transpose());
    ADRankTwoTensor A2=.5*(A1+A1.inverse().transpose());
    ADRankTwoTensor A3=.5*(A2+A2.inverse().transpose());
    ADRankTwoTensor Z=.5*(A3+A3.inverse().transpose());
    _stress[_qp].rotate(Z);
  }
  //_stress[_qp].rotate(Z); //making this incremental may add some stability...  (it doesn't really)
  
  
  //std::cout<<_stress[_qp];
  // Assign value for elastic strain, which is equal to the mechanical strain
  _elastic_strain[_qp] = _mechanical_strain[_qp];

}

template class ADComputeFiniteStrainElasticStressTemplH<RankTwoTensor, RankFourTensor>;
template class ADComputeFiniteStrainElasticStressTemplH<SymmetricRankTwoTensor,
                                                       SymmetricRankFourTensor>;
