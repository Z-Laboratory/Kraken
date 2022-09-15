//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "tmp_NH_stress.h"
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

registerMooseObject("TensorMechanicsApp", H2_ADComputeFiniteStrainElasticStress);
registerMooseObject("TensorMechanicsApp", H2_ADSymmetricFiniteStrainElasticStress);

template <typename R2, typename R4>
InputParameters
ADComputeFiniteStrainElasticStressTemplH2<R2, R4>::validParams()
{
  InputParameters params = ADComputeStressBase::validParams();
  params.addClassDescription("Compute stress using elasticity for finite strains");
  params.addRequiredParam<Real>("mu", "value of mu");
  params.addRequiredParam<Real>("kappa", "value of kappa");
  return params;
}

template <typename R2, typename R4>
ADComputeFiniteStrainElasticStressTemplH2<R2, R4>::ADComputeFiniteStrainElasticStressTemplH2(
    const InputParameters & parameters)
  : ADComputeStressBaseTempl<R2>(parameters),
    _mu(this->template getParam<Real>("mu")),
    _kappa(this->template getParam<Real>("kappa")),
    GuaranteeConsumer(this),
    _elasticity_tensor_name(_base_name + "elasticity_tensor"),
    _elasticity_tensor(this->template getADMaterialProperty<R4>(_elasticity_tensor_name)),
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
ADComputeFiniteStrainElasticStressTemplH2<R2, R4>::initialSetup()
{
}

template <typename R2, typename R4>
void
ADComputeFiniteStrainElasticStressTemplH2<R2, R4>::initQpStatefulProperties()
{
  ADComputeStressBaseTempl<R2>::initQpStatefulProperties();
  _rotation_total[_qp] = RankTwoTensor::Identity();
}

template <typename R2, typename R4>
void
ADComputeFiniteStrainElasticStressTemplH2<R2, R4>::computeQpStress()
{
  // Calculate the stress in the intermediate configuration
  ADR2 intermediate_stress;
  
  ADR2 NH;
  

  
  ADR2 F_tmp=_F_total[_qp];
  ADR2 B_inc=ADR2::timesTranspose(F_tmp);
  ADR2 I(ADR2::initIdentity);
  //NH=_elasticity_tensor[_qp]*B_inc-I*_kappa*(1-_F_total[_qp].det());
  NH=2*_mu*B_inc-I*_kappa*(1-_F_total[_qp].det());

  FADR2 Chat = ADR2::transposeTimes(F_tmp);
  FADR2 Uhat = MathUtils::sqrt(Chat);
  
  ADRankTwoTensor Z;
  ADRankTwoTensor Q;
  Q=F_tmp;
  Z = Q * Uhat.inverse().template get<ADRankTwoTensor>();

  
  
  _stress[_qp]=NH;
  //_stress[_qp].rotate(Z); we may need this. 
  
  
  //std::cout<<_stress[_qp];
  // Assign value for elastic strain, which is equal to the mechanical strain
  _elastic_strain[_qp] = _mechanical_strain[_qp];

}

template class ADComputeFiniteStrainElasticStressTemplH2<RankTwoTensor, RankFourTensor>;
template class ADComputeFiniteStrainElasticStressTemplH2<SymmetricRankTwoTensor,
                                                       SymmetricRankFourTensor>;
