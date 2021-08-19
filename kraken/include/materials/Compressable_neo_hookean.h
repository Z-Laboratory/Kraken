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

/**
 * Custom_ADComputeLinearElasticStress computes the stress following linear elasticity theory (small
 * strains)
 */
class Compressable_neo_hookean : public ADComputeStressBase
{
public:
  static InputParameters validParams();

  Compressable_neo_hookean(const InputParameters & parameters);

  virtual void initialSetup() override;

protected:
  virtual void computeQpStress() override;

  const ADMaterialProperty<RankTwoTensor> & _F;

  // from input file
  const double & _mu;
  const double & _kappa;
  const bool & _compressable;
};
