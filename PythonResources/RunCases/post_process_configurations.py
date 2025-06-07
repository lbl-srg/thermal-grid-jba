import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

import numpy as np

plt.rcParams['axes.facecolor']='whitesmoke'
plt.rcParams['font.size'] = 8
plt.rcParams['lines.linewidth'] = 1
plt.rcParams['text.usetex'] = False
plt.rcParams['legend.facecolor'] = 'white'
plt.rcParams['legend.framealpha'] = 0.75
plt.rcParams['legend.edgecolor'] = 'none'
plt.rcParams['savefig.dpi'] = 300

AFlo = 111997 # Floor area in m2

def save_plot(figure, file_name):
    """ Save the figure to a pdf and png file in the directory `img`
    """
    import os
    import matplotlib.pyplot as plt

    out_dir = "img"
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)
    figure.savefig(os.path.join(out_dir, '{}.pdf'.format(file_name)), bbox_inches='tight')
    figure.savefig(os.path.join(out_dir, '{}.png'.format(file_name)), bbox_inches='tight')
    plt.clf()


def configure_axes(axes):
    """ Configure the axis style
    """
    axes.spines['right'].set_visible(False)
    axes.spines['top'].set_visible(False)
    axes.spines['left'].set_visible(False)
    axes.spines['bottom'].set_visible(False)
    axes.grid(color='lightgrey', linewidth=0.25)
    return

def get_results(case_name: str):
    """ Get the results for the case with name `case_name`
    """
    import os
    import cases

    from buildingspy.io.outputfile import Reader
    # Make sure simulation was successful
    dslog_name = os.path.join("simulations", case_name, "dslog.txt")
    with open(dslog_name) as dslog:
       if not "Integration terminated successfully" in dslog.read():
           raise Exception("Simulation failed. Check {}".format(dslog_name))
    file_name = cases.get_result_file_name(case_name)
#     file_name = os.path.join("simulations", "DetailedPlantFiveHubs.mat")
    return Reader(file_name, "dymola")

def get_partial_results(case_name, list_of_variables):
    """ Get a dictionary with the variable names and the time series for `list_of_variables`
    """
    reader = get_results(case_name)
    d = dict()
    read_time = True
    for v in list_of_variables:
        if read_time:
            d['time'] = reader.values(v)[0]
            read_time = False
        d[v] = reader.values(v)[1]
    return d

# ---------------------------------------------------------------------------
# helper functions and scripts

def set_title(ax, title):
    left, width = .01, .97
    bottom, height = .01, .88
    right = left + width
    top = bottom + height

    title_str = r"$\it{" + title + "}$"
    ax.text(left, top,
            title_str,
            verticalalignment = 'center',
            horizontalalignment = 'left',
            transform=ax.transAxes,
            fontsize = 6, color = 'k',
            bbox=dict(facecolor='white', alpha=0.75, edgecolor='none'))


def tem_conv_CtoF(T_in_degC):
    '''Converts temperature provided in degC to degF
    '''
    T_in_degF = (T_in_degC)*9./5. + 32.

    return T_in_degF

def add_secondary_yaxis_for_degF(ax, time, temp_in_K):
        # Add a secondary axis with temperatures represented in F
        ax_F = ax.twinx()
        # Get limits to match with the left axis
        ax_F.set_ylim([tem_conv_CtoF(ax.get_ylim()[0]),tem_conv_CtoF(ax.get_ylim()[1])])
        # plot a "scaler" variable and make it invisible
        ax_F.plot(time, tem_conv_CtoF(temp_in_K-273.15), linewidth=0.0)
        ax_F.set_ylabel('temperature [$^\\circ$F]')
        configure_axes(ax_F)
        #ax.grid(False)
        #ax.xaxis.grid()

def hide_tick_labels(ax):
    '''Removes labels and ticks. Kwargs: bottom controls the ticks, labelbottom the tick labels
    '''
    ax.tick_params(axis = 'x',labelbottom='off',bottom='off')




def plot_energy(results : list, case_names: list):
    import os
    import matplotlib.pyplot as plt
    import numpy as np

    from buildingspy.io.outputfile import Reader

    plt.clf()

    n = len(results)
    # Conversion from J to kWh/m2

    conv = 1/3600./1000./AFlo
    width = 0.5       # the width of the bars: can also be len(x) sequence

    EHeaPum = np.zeros(n)
    EComPla = np.zeros(n)
    EPumETS = np.zeros(n)
    EPumDis = np.zeros(n)
    EPumPla = np.zeros(n)
    EFanDry = np.zeros(n)
    EFanBui = np.zeros(n)
    EEleNon = np.zeros(n)
    EAllTot = np.zeros(n)


    idx = np.array([i for i in range(n)])
    for i in idx:
        res = results[i]

        EHeaPum[i]        = res.max('EHeaPum.y') * conv
        EComPla[i]        = res.max('EComPla.y') * conv
        EPumETS[i]        = res.max('EPumETS.y') * conv
        EPumDis[i]        = res.max('EPumDis.y') * conv
        EPumPla[i]        = res.max('EPumPla.y') * conv
        EFanDry[i]        = res.max('EFanDryCoo.y') * conv
        EFanBui[i]        = res.max('EFanBui.y') * conv
        EEleNon[i]        = res.max('EEleNonHvaETS.y') * conv
        EAllTot[i]        = res.max('ETot.y') * conv


    bottom = np.zeros(n)
    p0 = plt.bar(idx, EHeaPum, width, bottom=bottom)
    bottom = np.add(bottom, EHeaPum)
    p1 = plt.bar(idx, EComPla, width, bottom=bottom)
    bottom = np.add(bottom, EComPla)
    p2 = plt.bar(idx, EPumETS, width, bottom=bottom)
    bottom = np.add(bottom, EPumETS)
    p3 = plt.bar(idx, EPumDis, width, bottom=bottom)
    bottom = np.add(bottom, EPumDis)
    p4 = plt.bar(idx, EPumPla, width, bottom=bottom)
    bottom = np.add(bottom, EPumPla)
    p5 = plt.bar(idx, EFanDry, width, bottom=bottom)
    bottom = np.add(bottom, EFanDry)
    p6 = plt.bar(idx, EFanBui, width, bottom=bottom)
    bottom = np.add(bottom, EFanBui)
    p7 = plt.bar(idx, EEleNon, width, bottom=bottom)
    bottom = np.add(bottom, EEleNon)

    print(f"All electricity use = {EAllTot}")
    print(f"Sum of plot = {bottom}")
    np.testing.assert_allclose(EAllTot, bottom, err_msg="Expected energy to be the same.")

    plt.ylabel('site electricity use $\mathrm{[kWh/(m^2 \cdot a)]}$')
    plt.xticks(idx, case_names)
    plt.tick_params(axis=u'x', which=u'both',length=0)

    #plt.yticks(np.arange(0, 81, 10))
    plt.legend(tuple(reversed((p0[0], p1[0], p2[0], p3[0], p4[0], p5[0], p6[0], p7[0]))), \
               tuple(reversed(('heat pumps in ETS', 'heat pump in plant', 'pumps in ETS', 'pumps for district loop', 'pumps in  plant', 'fans in plant', 'fans in buildings', 'non-HVAC electricity for buildings'))), \
               bbox_to_anchor=(1.5, 0.75), loc='right')
    #plt.tight_layout()

    save_plot(plt, "energy")

    # Write result to console and file
    # heat pumps ets
    # heat pumps in plant
    # pumps and fans
    # non-hvac electricity for buildings
    # Total
    # Energy [GWh/a] Energy [kWh/(m a)] Energy costs [USD/a]  Energy costs [USD/(m2 a)]
    #
    k=0
    head=u"""
\\begin{tabular}{ld{3.2}d{3.2}}
 &  \\multicolumn{1}{l}{Energy} &
 \\multicolumn{1}{l}{Specific energy} \\\\
 &
 \\multicolumn{1}{l}{$\mathrm{[GWh/a]}$} &
 \\multicolumn{1}{l}{$\mathrm{[kWh/(m2 \, a)]}$} \\\\ \hline"""

    vals=f"""
Heat pumps in ETS   & {EHeaPum[k]*AFlo*1000/1e9:.2f} &  {EHeaPum[k]:.1f} \\\\
Heat pumps in plant & {EComPla[k]*AFlo*1000/1e9:.2f} &  {EComPla[k]:.1f} \\\\
Pumps               & {(EPumETS[k]+EPumDis[k]+EPumPla[k])*AFlo*1000/1e9:.2f} &  {(EPumETS[k]+EPumDis[k]+EPumPla[k]):.1f} \\\\
Fans                & {(EFanDry[k]+EFanBui[k])*AFlo*1000/1e9:.2f} &  {(EFanDry[k]+EFanBui[k]):.1f} \\\\
Non-HVAC electricity for buildings & {EEleNon[k]*AFlo*1000/1e9:.2f} &  {EEleNon[k]:.1f}  \\\\ \hline
Total & {EAllTot[k]*AFlo*1000/1e9:.2f} &  {EAllTot[k]:.1f} \\\\ \hline"""
    foot=u"""
    \end{tabular}
    """
    print(vals)
    tab=head + vals + foot
    with open(os.path.join("img", "energyUseMod.tex"), 'w') as f:
        f.write(tab)


def plot_loop_temperatures(results : list, case_names: list):
    from buildingspy.io.outputfile import Reader
    import matplotlib.pyplot as plt

    nCas = len(case_names)

    for i in range(nCas):

        plt.clf()

        (tP, TDryBul)     = results[i].values('weaBus.TDryBul')
        (tP, TLooMin)     = results[i].values('cenPla.TLooMin')
        (tP, TLooMax)     = results[i].values('cenPla.TLooMax')
        (t, TLooMinMea)   = results[i].values('cenPla.TLooMinMea')
        (t, TLooMaxMea)   = results[i].values('cenPla.TLooMaxMea')
        (t, TSoiPer)      = results[i].values('dTSoiPer.T')
        (t, TSoiCen)      = results[i].values('dTSoiCen.T')

        fig, axs = plt.subplots(nrows=2, ncols=1, sharex=True)

        axs[0].plot(t/24./3600., TDryBul-273.15, 'k', label='Outside air temperature', linewidth=0.1)
        axs[0].plot(t/24./3600., TLooMinMea-273.15, 'b', label='Minimum loop temperature', linewidth=0.2)
        axs[0].plot(t/24./3600., TLooMaxMea-273.15, 'r', label='Maximum loop temperature', linewidth=0.2)
        axs[0].plot(t/24./3600., TSoiCen-273.15, 'k', label='Average temperature center borefield', linewidth=0.5)
        axs[0].plot(t/24./3600., TSoiPer-273.15, 'g', label='Average temperature perimeter borefield', linewidth=0.5)

        rect1 = matplotlib.patches.Rectangle((tP[0], 0), 365, TLooMin[0]-273.15, color='mistyrose')
        axs[0].add_patch(rect1)
        rect1 = matplotlib.patches.Rectangle((tP[0], TLooMax[0]-273.15), 365, 30, color='mistyrose')
        axs[0].add_patch(rect1)

        axs[0].set_ylabel(r'Temperature [$^\circ$C]')
        #axs[0].set_xticks(list(range(25)))
        axs[0].set_xlim([0, 365])
        axs[0].set_ylim([-13, 42])
        axs[0].legend(bbox_to_anchor=(1.05, 1.0), loc='upper left')
        #ax.set_aspect(5)
        configure_axes(axs[0])

        # Energy
        (t, EETS)     = results[i].values('ETotEts.y')
        (t, EHexDry)  = results[i].values('cenPla.EHexEne.y')
        (t, EBorCen)  = results[i].values('dTSoiCen.E')
        (t, EBorPer)  = results[i].values('dTSoiPer.E')
        (t, EHPCen)   = results[i].values('cenPla.EHeaPum.y')
        QPip = np.zeros(len(t))
        for k in range(1, 6):
            (_, tmp)     = results[i].values(f'dis.heatPorts[{k}].Q_flow')
            QPip = np.add(QPip, tmp)

        EPip = np.zeros(len(t))
        for k in range(len(t)-1):
            EPip[k+1] = EPip[k] + (QPip[k+1]+QPip[k])/2.*(t[k+1]-t[k])

        axs[1].plot(t/24./3600., -EETS/3600./1E9,    'b', label='Energy from ETS heat exchanger', marker=">", linewidth=0.5, markevery=60000, markersize=3)
        axs[1].plot(t/24./3600., EHexDry/3600./1E9, 'r', label='Energy from central plant economizer', marker=",", linewidth=0.5, markevery=3000, markersize=3)
        axs[1].plot(t/24./3600., -EBorCen/3600./1E9, 'k-+', label='Energy from center borefield', linewidth=0.2, markevery=60000, markersize=3)
        axs[1].plot(t/24./3600., -EBorPer/3600./1E9, 'k-*', label='Energy from perimeter borefield', linewidth=0.2, markevery=30000, markersize=3)
        axs[1].plot(t/24./3600., EPip/3600./1E9,    'k-o', label='Energy from soil into distribution pipe', linewidth=0.2, markevery=50000, markersize=3)
        axs[1].plot(t/24./3600., EHPCen/3600./1E9,  'g', label='Energy from central heat pump', marker="<", linewidth=0.5, markevery=60000, markersize=3)


        axs[1].set_xlabel('Time [d]')
        axs[1].set_ylabel('Energy [GWh/a]')
        #axs[1].set_xticks(list(range(25)))
        axs[1].set_xlim([0, 365])
        axs[1].set_ylim([-12, 12])
        axs[1].legend(bbox_to_anchor=(1.05, 1.0), loc='upper left')
        configure_axes(axs[1])
        plt.tight_layout()
        #plt.title()

        save_plot(plt, f"{case_names[i]}loopTemperatures")


def plotPlant(lis, res, filePrefix, days):
    from datetime import datetime

    ori_font_size = plt.rcParams['font.size']
    plt.rcParams['font.size'] = 4

    def get_minMaxIndex(tMin, tMax, t):
        iSta = 0
        for i in range(len(t)):
            if tMin >= t[i]:
                iSta = i
            else:
                break
        iEnd = 0
        for i in range(len(t)):
            if tMax >= t[i]:
                iEnd = i
            else:
                break

        return (iSta, iEnd)

    for day in days:
        plt.clf()

        tMin = day["xlim"][0]*24*3600.
        tMax = day["xlim"][1]*24*3600.
        (t, ySea) = res.values('cenPla.gen.ind.ySea')
        (iSta, iEnd) = get_minMaxIndex(tMin, tMax, t)

        # Take max so that axs is an array.
        fig, axs = plt.subplots(nrows=len(lis), ncols=1, sharex=True)
        k=0
        for i in range(len(lis)):
            for iVar in range(len(lis[i]["vars"])):
                ptrVar = lis[i]["vars"][iVar]
                (tAll, yAll) = res.values(ptrVar["var"])
                t = tAll[iSta:iEnd]
                y = yAll[iSta:iEnd]
                # Check if data series should be skipped to allow for seasonal configuration
                if not (("skip_if_ySea" in ptrVar) and (ptrVar["skip_if_ySea"] == ySea[iSta])):
                    axs[k].plot(t/3600., y * lis[i]["factor"] + lis[i]["offset"], label=ptrVar["label"],
                            linewidth=ptrVar["linewidth"] if "linewidth" in ptrVar else 0.2,
                            linestyle=ptrVar["linestyle"] if "linestyle" in ptrVar else "-",
                            marker=ptrVar["marker"] if "marker" in ptrVar else "",
                            markersize=2,
                            markevery=50)

            #axs[k].set_xlim([tMin, tMax])
            #axs[i].set_ylim([5, 25])
            axs[k].autoscale(True)
            configure_axes(axs[k])

            if iVar == len(lis[i]["vars"])-1:
                # Last variable to be plotted
                if i == len(lis)-1:
                    axs[k].set_xlabel(f"time [h] ({day['date']})")

                axs[k].set_ylabel(lis[i]["y_label"], multialignment='center')
                axs[k].legend(bbox_to_anchor=(1.25, 1.0),
                              loc='upper right',
                              ncol=2)
            #axs[i].set_ylim(lis[i]["y_lim"])

            k=k+1

        #fig.tight_layout()

        save_plot(plt, f"{filePrefix}{day['name']}")
        plt.rcParams['font.size'] = ori_font_size


def plotOneFigure(lis, res, filePrefix, days):
    from datetime import datetime

    ori_font_size = plt.rcParams['font.size']
    plt.rcParams['font.size'] = 8

    def get_minMaxIndex(tMin, tMax, t):
        iSta = 0
        for i in range(len(t)):
            if tMin >= t[i]:
                iSta = i
            else:
                break
        iEnd = 0
        for i in range(len(t)):
            if tMax >= t[i]:
                iEnd = i
            else:
                break

        return (iSta, iEnd)

    for day in days:
        plt.clf()

        tMin = day["xlim"][0]*24*3600.
        tMax = day["xlim"][1]*24*3600.
        (t, ySea) = res.values('cenPla.gen.ind.ySea')
        (iSta, iEnd) = get_minMaxIndex(tMin, tMax, t)

        # Take max so that axs is an array.
        fig, axs = plt.subplots(nrows=len(lis), ncols=1, sharex=True)
        k=0
        for i in range(len(lis)):
            for iVar in range(len(lis[i]["vars"])):
                ptrVar = lis[i]["vars"][iVar]
                (tAll, yAll) = res.values(ptrVar["var"])
                t = tAll[iSta:iEnd]
                y = yAll[iSta:iEnd]
                # Check if data series should be skipped to allow for seasonal configuration
                if not (("skip_if_ySea" in ptrVar) and (ptrVar["skip_if_ySea"] == ySea[iSta])):
                    axs.plot(t/3600./24., y * lis[i]["factor"] + lis[i]["offset"], label=ptrVar["label"],
                            linewidth=ptrVar["linewidth"] if "linewidth" in ptrVar else 0.2,
                            linestyle=ptrVar["linestyle"] if "linestyle" in ptrVar else "-",
                            marker=ptrVar["marker"] if "marker" in ptrVar else "",
                            markersize=2,
                            markevery=50)

            #axs[k].set_xlim([tMin, tMax])
            #axs[i].set_ylim([5, 25])
            axs.autoscale(True)
            configure_axes(axs)
            axs.set_aspect(25)

            if iVar == len(lis[i]["vars"])-1:
                # Last variable to be plotted
                if i == len(lis)-1:
                    axs.set_xlabel(f"time [day]")

                axs.set_ylabel(lis[i]["y_label"], multialignment='center')
                axs.legend(#bbox_to_anchor=(1.25, 1.0),
                              loc='lower right',
                              ncol=2)
            #axs[i].set_ylim(lis[i]["y_lim"])

            k=k+1

        #fig.tight_layout()

        save_plot(plt, f"{filePrefix}{day['name']}")
        plt.rcParams['font.size'] = ori_font_size


def convert_hourly(time, valSets):
    import numpy as np

    # find the indexes of the last occurrence of the duplicate time instants
    timeList = list(time)
    uniTim = set(timeList)
    print("Searching final time instances of the iteration ......")
    uniTimInd = [(len(timeList)-1-timeList[::-1].index(x)) for x in uniTim]
    print("-------- end -------")
    uniTimInd.sort()

    # Number of unique time instants
    n_uniTim = len(uniTim)
    uniTimLis = list(uniTim)
    uniTimLis.sort()
    # begin and end index of each hourly range
    print("Searching indexes of the begin and end moment of each hour .......")
    begin = []
    end = []
    for i in range(8760):
        for j in range(n_uniTim):
            if (uniTimLis[j] >= (i*3600)):
                begin.append(j)
                if j > 0:
                    end.append(j-1)
                break
    end.append(n_uniTim-1)
    print("-------- end -------")

    # find the final values after the iteration
    print("Searching final values after the iteration ......")
    setsWithFinalValues = []
    for i in range(len(valSets)):
        ele = valSets[i]
        temp = dict()
        temp['name'] = ele['name']
        temp['value'] = [ele['value'][j] for j in uniTimInd]
        setsWithFinalValues.append(temp)
    print("-------- end -------")

    # find the hourly average values
    print("Searching hourly values ......")
    hourlySets = []
    for i in range(len(setsWithFinalValues)):
        ele = setsWithFinalValues[i]
        hourlyValue = []
        for j in range(len(begin)):
            begInd = begin[j]
            endInd = end[j]
            if ('uSea' in ele['name']):
                hourlyValue.append(ele['value'][begInd])
            else:
                curHouVals = ele['value'][begInd:(endInd+1)]
                hourlyValue.append(np.mean(curHouVals))
        hourlySets.append({"name": ele['name'], "value": hourlyValue})
    print("-------- end -------")
    return hourlySets


def seasonal_specific_heat(result):
    timLog = result["time"]
    datPoi = len(timLog)
    # seaInd = temp_results["cenPla.gen.borCon.uSea"]
    seaInd = {'name': "uSea", 'value': result["cenPla.gen.borCon.uSea"]}
    borSpePer = {'name': "qBorSpePer_flow", 'value': result["cenPla.borFie.qBorSpePer_flow"]}
    borSpeCen = {'name': "qBorSpeCen_flow", 'value': result["cenPla.borFie.qBorSpeCen_flow"]}
    borSpe = {'name': "qBorSpe_flow", 'value': result["cenPla.borFie.qBorSpe_flow"]}

    speHea_hourly=convert_hourly(timLog, [seaInd, borSpePer, borSpeCen, borSpe])
    seaInd_hourly = speHea_hourly[0]
    borSpePer_hourly = speHea_hourly[1]
    borSpeCen_hourly = speHea_hourly[2]
    borSpe_hourly = speHea_hourly[3]

    # heat flow in winter
    win_qBorSpePer = []
    win_qBorSpeCen = []
    win_qBorSpe = []
    # heat flow in spring
    spr_qBorSpePer = []
    spr_qBorSpeCen = []
    spr_qBorSpe = []
    # heat flow in summer
    sum_qBorSpePer = []
    sum_qBorSpeCen = []
    sum_qBorSpe = []
    # heat flow in fall
    fal_qBorSpePer = []
    fal_qBorSpeCen = []
    fal_qBorSpe = []

    for i in range(len(seaInd_hourly['value'])):
        sea = seaInd_hourly['value'][i]
        if sea == 1:
            win_qBorSpePer.append(borSpePer_hourly['value'][i])
            win_qBorSpeCen.append(borSpeCen_hourly['value'][i])
            win_qBorSpe.append(borSpe_hourly['value'][i])
        elif sea == 2:
            spr_qBorSpePer.append(borSpePer_hourly['value'][i])
            spr_qBorSpeCen.append(borSpeCen_hourly['value'][i])
            spr_qBorSpe.append(borSpe_hourly['value'][i])
        elif sea == 3:
            sum_qBorSpePer.append(borSpePer_hourly['value'][i])
            sum_qBorSpeCen.append(borSpeCen_hourly['value'][i])
            sum_qBorSpe.append(borSpe_hourly['value'][i])
        else:
            fal_qBorSpePer.append(borSpePer_hourly['value'][i])
            fal_qBorSpeCen.append(borSpeCen_hourly['value'][i])
            fal_qBorSpe.append(borSpe_hourly['value'][i])
    speHea = dict()
    speHea['win_qBorSpePer']=win_qBorSpePer
    speHea['win_qBorSpeCen']=win_qBorSpeCen
    speHea['win_qBorSpe']=win_qBorSpe
    speHea['spr_qBorSpePer']=spr_qBorSpePer
    speHea['spr_qBorSpeCen']=spr_qBorSpeCen
    speHea['spr_qBorSpe']=spr_qBorSpe

    speHea['sum_qBorSpePer']=sum_qBorSpePer
    speHea['sum_qBorSpeCen']=sum_qBorSpeCen
    speHea['sum_qBorSpe']=sum_qBorSpe
    speHea['fal_qBorSpePer']=fal_qBorSpePer
    speHea['fal_qBorSpeCen']=fal_qBorSpeCen
    speHea['fal_qBorSpe']=fal_qBorSpe

    return speHea


def generate_specific_heat_plots(result: dict, case_name):
    import matplotlib.pyplot as plt
    import numpy as np

    # create dictionary of the specific heat flow rate in each season for each borefield
    speHea = seasonal_specific_heat(result)

    # Creating subplots with multiple histograms
    fig, axes = plt.subplots(nrows=2, ncols=2, figsize=(12, 6))

    axes[0][0].hist(speHea['win_qBorSpePer'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes[0][0].set_title('Winter, perimeter borefield')

    axes[0][1].hist(speHea['spr_qBorSpePer'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes[0][1].set_title('Spring, perimeter borefield')

    axes[1][0].hist(speHea['sum_qBorSpePer'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes[1][0].set_title('Summer, perimeter borefield')

    axes[1][1].hist(speHea['fal_qBorSpePer'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes[1][1].set_title('Fall, perimeter borefield')

    # Adding labels and title
    for i in range(2):
        for j in range(2):
            axes[i][j].set_xlabel('Specific heat flow rate [W/m]')
            axes[i][j].set_ylabel('Frequency [h/a]')

    # Adjusting layout for better spacing
    plt.tight_layout()

    save_plot(plt, case_name+"_perimeter_borefield")


    # Creating subplots with multiple histograms
    fig, axes1 = plt.subplots(nrows=2, ncols=2, figsize=(12, 6))

    axes1[0][0].hist(speHea['win_qBorSpeCen'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes1[0][0].set_title('Winter, center borefield')

    axes1[0][1].hist(speHea['spr_qBorSpeCen'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes1[0][1].set_title('Spring, center borefield')

    axes1[1][0].hist(speHea['sum_qBorSpeCen'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes1[1][0].set_title('Summer, center borefield')

    axes1[1][1].hist(speHea['fal_qBorSpeCen'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes1[1][1].set_title('Fall, center borefield')

    # Adding labels and title
    for i in range(2):
        for j in range(2):
            axes1[i][j].set_xlabel('Specific heat flow rate [W/m]')
            axes1[i][j].set_ylabel('Frequency [h/a]')

    # Adjusting layout for better spacing
    plt.tight_layout()

    save_plot(plt, case_name+"_center_borefield")


    # Creating subplots with multiple histograms
    fig, axes2 = plt.subplots(nrows=2, ncols=2, figsize=(12, 6))

    axes2[0][0].hist(speHea['win_qBorSpe'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes2[0][0].set_title('Winter, both borefields')

    axes2[0][1].hist(speHea['spr_qBorSpe'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes2[0][1].set_title('Spring, both borefields')

    axes2[1][0].hist(speHea['sum_qBorSpe'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes2[1][0].set_title('Summer, both borefields')

    axes2[1][1].hist(speHea['fal_qBorSpe'], bins=np.arange(-50, 50, 2.5), color='lightgrey', edgecolor='black')
    axes2[1][1].set_title('Fall, both borefields')

    # Adding labels and title
    for i in range(2):
        for j in range(2):
            axes2[i][j].set_xlabel('Specific heat flow rate [W/m]')
            axes2[i][j].set_ylabel('Frequency [h/a]')

    # Adjusting layout for better spacing
    plt.tight_layout()

    save_plot(plt, case_name+"_both_borefields")


def plot_borefield_specific_heat(results : list, case_names: list, list_of_variables: list):
    for i in range(len(results)):
        res = results[i]
        d = dict()
        read_time = True
        for v in list_of_variables:
            if read_time:
                d['time'] = res.values(v)[0]
                read_time=False
            d[v] = res.values(v)[1]
        generate_specific_heat_plots(d, case_names[i])


def dT_hour(time, TLooMin, TLooMax, TLooMinMea, TLooMaxMea):
    import numpy as np
    dT = []
    dTMax = []
    dTMin = []
    for i in range(len(TLooMinMea)):
        dt_max = TLooMaxMea[i] - TLooMax[0]
        dt_min = TLooMin[0] - TLooMinMea[i]
        dTMax.append(dt_max)
        dTMin.append(dt_min)
        dT.append(max(0, dt_min, dt_max))
    dTHou = (np.trapezoid(dT, time)) / 3600
    return dTHou

def write_latex_capacity_table(r,
                               nBui = None):
    """ Returns texts for a latex table.
        Requires the `unyt` package for unit handling.
        r : BuildingsPy Reader object;
        nBui : Number of ETS, if not given will read `nBui` from mat file.
    """
    
    import unyt as yt
    # There appears to be no way to remove a user-defined unit from the
    #   UnitRegistry once defined. The console must be restarted.
    yt.define_unit("kBTU", 1000 * yt.BTU)
    yt.define_unit("RT", 12000 * yt.Unit("BTU/hr")) # refrigeration ton
    #yt.define_unit("inH2O", 249.089 * yt.Unit("Pa"))
    yt.define_unit("GPM_H2O", 1/15.85 * yt.Unit("kg/s"))
    yt.define_unit("GPM_Glycol", 1/15.85/1.11 * yt.Unit("kg/s"))
    # glycol density = 1.11e3 kg/m3
    yt.define_unit("CFM_Air", 1/1.293*3.28**3*60 * yt.Unit("kg/s"))
    # 1 kg/s / 1.293 kg/m3 * 3.28^3 (ft3/m3) * 60 min/s = 1637 cfm
    
    def read_parameter(varName):
        """ Returns the first value of a series read from mat file.
        """
        (t, y) = r.values(varName)
        return y[0]

    def read_max_abs(varName):
        """ Returns the max of abs of a series read from the mat file.
        """
        return max(r.max(varName), abs(r.min(varName)))
    
    def write_row(val,
                  desc,
                  unit_mat,
                  unit_si,
                  unit_ip,
                  format_si = ',.0f',
                  format_ip = ',.0f',
                  display_si = None,
                  display_ip = None):
        
        """ Returns one row for the latex table.
            `val`           the value to be put in the table,
            `desc`          description of the value,
            `unit_mat`      the input unit,
            `unit_si`       the si unit to be printed,
            `unit_ip`       the ip unit to be printed,
            `format_si`     format control string of the si number,
            `format_ip`     format control string of the ip number,
            `display_si`    how the unit is printed, leave as None if same as `unit_si`
            `display_ip`    same as above. 
        """
        
        tab = ""
        
        val_si = float((val * yt.Unit(unit_mat)).in_units(yt.Unit(unit_si)).value)
        val_ip = float((val * yt.Unit(unit_mat)).in_units(yt.Unit(unit_ip)).value)
        if display_si is None:
            display_si = unit_si
        if display_ip is None:
            display_ip = unit_ip
        tab += f" & {desc} & {val_si:{format_si}} & {display_si} & {val_ip:{format_ip}} & {display_ip} \\\\\n"
        
        return tab
    
    ### main function ###
    
    if nBui is None:
        nBui = int(read_parameter('nBui'))
    
    # header
    tab = ""
    tab += r"% generated by `write_latex_capacity_table()` in PythonResources/RunCases/post_process_configurations.py\n\n"
    tab += "\\begin{tabular}{llrlrl}\n"
    tab += "\\toprule\n"
    tab += " & System capacity & \\multicolumn{2}{c}{SI unit} & \\multicolumn{2}{c}{IP unit} \\\\\n"
    tab += "\\hline\n"
    
    # main body
    ## ETS
    for i in range(1,nBui+1):
        
        # chiller
        tab += f"ETS {i}" # This will go bofore the `&` of the first row
        
        tab += write_row(val = read_parameter(f'bui[{i}].ets.chi.chi.QHea_flow_nominal'),
                         desc = "Heat recovery chiller - heating",
                         unit_mat = "W",
                         unit_si = "kW",
                         unit_ip = "kBTU/hr",
                         display_ip = "kBtu/hr")
        
        tab += write_row(val = abs(read_parameter(f'bui[{i}].ets.chi.chi.QCoo_flow_nominal')),
                         desc = "Heat recovery chiller - cooling",
                         unit_mat = "W",
                         unit_si = "kW",
                         unit_ip = "RT",
                         display_ip = "ton")
        
        # hex
        tab += write_row(val = read_parameter(f'bui[{i}].hexSiz.Q_flow_nominal'),
                         desc = "District heat exchanger",
                         unit_mat = "W",
                         unit_si = "kW",
                         unit_ip = "kBTU/hr",
                         display_ip = "kBtu/hr")
    
        # dhw
        if i != 1: # Bui[1] doesn't have dhw.
            tab += write_row(val = read_parameter(f'bui[{i}].datDhw.VTan'),
                             desc = "Domestic hot water tank",
                             unit_mat = "m**3",
                             unit_si = "m**3",
                             unit_ip = "gal_US",
                             display_si = "m$^3$",
                             display_ip = "gal")
        
        tab += "\\hline\n"
    
    ## central plant
    tab += "Central plant"
    
    tab += write_row(val = read_parameter('cenPla.gen.heaPum.QHea_flow_nominal'),
                     desc = "Heat pump - heating",
                     unit_mat = "W",
                     unit_si = "kW",
                     unit_ip = "kBTU/hr",
                     display_ip = "kBtu/hr")
    
    tab += write_row(val = abs(read_parameter('cenPla.gen.heaPum.QCoo_flow_nominal')),
                     desc = "Heat pump - cooling",
                     unit_mat = "W",
                     unit_si = "kW",
                     unit_ip = "RT",
                     display_ip = "ton")
    
    # dry cooler
    tab += write_row(val = read_parameter('cenPla.gen.fanDryCoo.m_flow_nominal')/1.293,
                     desc = "Dry cooler - air side",
                     unit_mat = "m**3/s",
                     unit_si = "m**3/hr",
                     unit_ip = "ft**3/min",
                     display_si = "m3/h",
                     display_ip = "cfm")
    
    tab += write_row(val = read_parameter('cenPla.gen.pumDryCoo.m_flow_nominal'),
                     desc = "Dry cooler - glycol side",
                     unit_mat = "kg/s",
                     unit_si = "kg/s",
                     unit_ip = "GPM_Glycol",
                     display_ip = "gpm")
    
    # borefield
    tab += write_row(val = read_max_abs('EBorPer.y'),
                     desc = "Borefield perimeter zone",
                     unit_mat = "J",
                     unit_si = "MWh",
                     unit_ip = "MMBTU",
                     display_ip = "MMBtu")
    
    tab += write_row(val = read_max_abs('EBorCen.y'),
                     desc = "Borefield center zone",
                     unit_mat = "J",
                     unit_si = "MWh",
                     unit_ip = "MMBTU",
                     display_ip = "MMBtu")
    
    tab += "\\hline\n"
    
    ## district
    tab += "District network"
    
    tab += write_row(val = read_parameter('datDis.mPumDis_flow_nominal'),
                     desc = "Distribution pump flow rate",
                     unit_mat = "kg/s",
                     unit_si = "kg/s",
                     unit_ip = "GPM_H2O",
                     display_ip = "gpm")
    
    tab += write_row(val = read_parameter('pumDis.dp_nominal'),
                     desc = "Distribution pump pressure rise",
                     unit_mat = "Pa",
                     unit_si = "kPa",
                     unit_ip = "psi")
    
    # length of pipes
    l = 0
    for i in range(1,nBui+2):
        l += read_parameter(f'datDis.lDis[{i}]')
    tab += write_row(val = l,
                     desc = "District piping",
                     unit_mat = "m",
                     unit_si = "m",
                     unit_ip = "ft")
    
    l = 0
    for i in range(1,nBui+1):
        l += read_parameter(f'datDis.lCon[{i}]') * 2
    tab += write_row(val = l,
                     desc = "Connection piping",
                     unit_mat = "m",
                     unit_si = "m",
                     unit_ip = "ft")
    
    # footer
    tab += "\\bottomrule\n"
    tab += "\\end{tabular}"
    
    return tab