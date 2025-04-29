#include <vpi_user.h>
#include <stdlib.h>
#include "filesystem.c"

static int init_fs(char*user_data)
{
    vpiHandle sys = vpi_handle(vpiSysTfCall, 0);
    vpiHandle argv = vpi_iterate(vpiArgument, sys);

    s_vpi_value root;
    root.format = vpiStringVal;
    vpi_get_value(vpi_scan(argv), &root);

    init(root.value.str);
    return 0;
}

static int cleanup_fs(char*user_data)
{
    cleanup();
    return 0;
}

static int tick_fs(char*user_data)
{
    vpiHandle sys = vpi_handle(vpiSysTfCall, 0);
    vpiHandle argv = vpi_iterate(vpiArgument, sys);

    s_vpi_value swapMeta, swapAddress, swapRden, swapWren, swapWriteData,
        syscallId, pathPtr, pathPtr2, fileDescriptor, fileAddress, fileBits, fileWriteData;

    swapMeta.format = swapAddress.format = swapRden.format = swapWren.format = swapWriteData.format =
        syscallId.format = pathPtr.format = pathPtr2.format = fileDescriptor.format = fileAddress.format = fileBits.format = fileWriteData.format = vpiIntVal;
    vpi_get_value(vpi_scan(argv), &swapMeta);
    vpi_get_value(vpi_scan(argv), &swapAddress);
    vpi_get_value(vpi_scan(argv), &swapRden);
    vpi_get_value(vpi_scan(argv), &swapWren);
    vpi_get_value(vpi_scan(argv), &swapWriteData);
    vpi_get_value(vpi_scan(argv), &syscallId);
    vpi_get_value(vpi_scan(argv), &pathPtr);
    vpi_get_value(vpi_scan(argv), &pathPtr2);
    vpi_get_value(vpi_scan(argv), &fileDescriptor);
    vpi_get_value(vpi_scan(argv), &fileAddress);
    vpi_get_value(vpi_scan(argv), &fileBits);
    vpi_get_value(vpi_scan(argv), &fileWriteData);

    uint32_t* dataOut = malloc(4);
    *dataOut = 0;

    uint32_t* swapReadData = malloc(4);
    *swapReadData = 0;

    tick(&swapMeta.value.integer, &swapAddress.value.integer, &swapRden.value.integer, swapReadData,
         &swapWren.value.integer, &swapWriteData.value.integer, &syscallId.value.integer,
         &pathPtr.value.integer, &pathPtr2.value.integer, &fileDescriptor.value.integer,
         &fileAddress.value.integer, &fileBits.value.integer, &fileWriteData.value.integer,
         dataOut);

    struct t_vpi_vecval vector[2];
    vector[0].aval = *dataOut;
    vector[0].bval = 0;
    vector[1].aval = *swapReadData;
    vector[1].bval = 0;

    s_vpi_value result;
    result.format = vpiVectorVal;
    result.value.vector = vector;
    vpi_put_value(sys, &result, 0, vpiNoDelay);

    free(dataOut);
    free(swapReadData);

    return 64;
}

static PLI_INT32 sizetf_64 (PLI_BYTE8* name) { return 64; }

void register_funcs()
{
    s_vpi_systf_data tf_data;

    tf_data.type      = vpiSysTask;
    tf_data.tfname    = "$init_fs";
    tf_data.calltf    = init_fs;
    tf_data.compiletf = 0;
    tf_data.sizetf    = 0;
    tf_data.user_data = 0;
    vpi_register_systf(&tf_data);

    tf_data.type      = vpiSysTask;
    tf_data.tfname    = "$cleanup_fs";
    tf_data.calltf    = cleanup_fs;
    tf_data.compiletf = 0;
    tf_data.sizetf    = 0;
    tf_data.user_data = 0;
    vpi_register_systf(&tf_data);

    tf_data.type      = vpiSysFunc;
    tf_data.sysfunctype = vpiSizedFunc;
    tf_data.tfname    = "$tick_fs";
    tf_data.calltf    = tick_fs;
    tf_data.compiletf = 0;
    tf_data.sizetf    = sizetf_64;
    tf_data.user_data = 0;
    vpi_register_systf(&tf_data);
}

void (*vlog_startup_routines[])() = {
    register_funcs,
    0
};