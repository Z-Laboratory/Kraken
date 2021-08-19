#include "KrakenApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
KrakenApp::validParams()
{
  InputParameters params = MooseApp::validParams();

  // Do not use legacy DirichletBC, that is, set DirichletBC default for preset = true
  params.set<bool>("use_legacy_dirichlet_bc") = false;

  return params;
}

KrakenApp::KrakenApp(InputParameters parameters) : MooseApp(parameters)
{
  KrakenApp::registerAll(_factory, _action_factory, _syntax);
}

KrakenApp::~KrakenApp() {}

void
KrakenApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAll(f, af, s);
  Registry::registerObjectsTo(f, {"KrakenApp"});
  Registry::registerActionsTo(af, {"KrakenApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
KrakenApp::registerApps()
{
  registerApp(KrakenApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
KrakenApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  KrakenApp::registerAll(f, af, s);
}
extern "C" void
KrakenApp__registerApps()
{
  KrakenApp::registerApps();
}
