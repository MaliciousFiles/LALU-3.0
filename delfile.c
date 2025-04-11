#include <vpi_user.h>
#include <stdlib.h>

static int delfile_calltf(char*user_data)
{
      vpiHandle sys = vpi_handle(vpiSysTfCall, 0);
      vpiHandle argv = vpi_iterate(vpiArgument, sys);

      s_vpi_value name;
      name.format = vpiStringVal;
      vpi_get_value(vpi_scan(argv), &name);

      remove(name.value.str);
      return 0;
}

void delfile_register()
{
      s_vpi_systf_data tf_data;

      tf_data.type      = vpiSysTask;
      tf_data.tfname    = "$delfile";
      tf_data.calltf    = delfile_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);
}

void (*vlog_startup_routines[])() = {
    delfile_register,
    0
};