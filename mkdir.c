#include <vpi_user.h>
#include <stdlib.h>

static int mkdir_calltf(char*user_data)
{
      vpiHandle sys = vpi_handle(vpiSysTfCall, 0);
      vpiHandle argv = vpi_iterate(vpiArgument, sys);

      s_vpi_value name;
      name.format = vpiStringVal;
      vpi_get_value(vpi_scan(argv), &name);

      char* command;
      asprintf(&command, "mkdir -p $(dirname '%s')", name.value.str);
      system(command);
      free(command);

      return 0;
}

void mkdir_register()
{
      s_vpi_systf_data tf_data;

      tf_data.type      = vpiSysTask;
      tf_data.tfname    = "$mkdir";
      tf_data.calltf    = mkdir_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);
}

void (*vlog_startup_routines[])() = {
    mkdir_register,
    0
};