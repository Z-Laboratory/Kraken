//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "KrakenTestApp.h"
#include "KrakenApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

InputParameters
KrakenTestApp::validParams()
{
  InputParameters params = KrakenApp::validParams();
  return params;
}

KrakenTestApp::KrakenTestApp(InputParameters parameters) : MooseApp(parameters)
{
  KrakenTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

KrakenTestApp::~KrakenTestApp() {}

void
KrakenTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  KrakenApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"KrakenTestApp"});
    Registry::registerActionsTo(af, {"KrakenTestApp"});
  }
}

void
KrakenTestApp::registerApps()
{
  registerApp(KrakenApp);
  registerApp(KrakenTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
KrakenTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  KrakenTestApp::registerAll(f, af, s);
}
extern "C" void
KrakenTestApp__registerApps()
{
  KrakenTestApp::registerApps();
}
