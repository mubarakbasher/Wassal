import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/datasources/voucher_remote_data_source.dart';
import '../../data/repositories/voucher_repository_impl.dart';
import '../bloc/voucher_bloc.dart';
import '../bloc/voucher_event.dart';
import '../bloc/voucher_state.dart';
import '../widgets/voucher_success_dialog.dart';

class GenerateVoucherPage extends StatelessWidget {
  const GenerateVoucherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VoucherBloc(
        repository: VoucherRepositoryImpl(
          remoteDataSource: VoucherRemoteDataSourceImpl(apiClient: ApiClient()),
        ),
      )..add(LoadVoucherFormData()),
      child: const GenerateVoucherView(),
    );
  }
}

class GenerateVoucherView extends StatefulWidget {
  const GenerateVoucherView({super.key});

  @override
  State<GenerateVoucherView> createState() => _GenerateVoucherViewState();
}

class _GenerateVoucherViewState extends State<GenerateVoucherView> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController(text: "10");
  final _quantityController = TextEditingController(text: "1");
  
  // Limit Controls
  String _limitType = "Time"; // "Time" or "Data"
  final _limitValueController = TextEditingController(text: "1");
  String _timeUnit = "Hours"; // Minutes, Hours, Days
  String _dataUnit = "GB"; // MB, GB

  String? _selectedProfileId;
  String? _selectedPlanName; // To display in voucher
  

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _limitValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Print Voucher"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocConsumer<VoucherBloc, VoucherState>(
        listener: (context, state) {
          if (state is VoucherError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is VoucherGenerated) {
             showDialog(
               context: context,
               barrierDismissible: false,
               builder: (_) => VoucherSuccessDialog(
                 vouchers: state.vouchers,
                 onDismiss: () {
                   Navigator.pop(context); // Close dialog
                   // Optionally reset form or load data again
                   context.read<VoucherBloc>().add(LoadVoucherFormData());
                 },
               ),
             );
          }
        },
        builder: (context, state) {
           if (state is VoucherLoading && state is! VoucherFormDataLoaded) {
             return const Center(child: CircularProgressIndicator());
           }
           
           if (state is VoucherFormDataLoaded || state is VoucherGenerated || state is VoucherError) {
              final formData = state is VoucherFormDataLoaded ? state : 
                              (state is VoucherGenerated ? context.read<VoucherBloc>().state : 
                              (state is VoucherError ? context.read<VoucherBloc>().state : null));

              if (formData is! VoucherFormDataLoaded) {
                  return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Text("Select Router", style: TextStyle(fontWeight: FontWeight.bold)),
                       const SizedBox(height: 8),
                       DropdownButtonFormField<String>(
                         value: formData.selectedRouterId,
                         decoration: const InputDecoration(border: OutlineInputBorder()),
                         items: formData.routers.map((router) {
                           return DropdownMenuItem(
                             value: router['id'] as String,
                             child: Text(router['name'] ?? "Unknown"),
                           );
                         }).toList(),
                         onChanged: (value) {
                           if (value != null) {
                             context.read<VoucherBloc>().add(SelectRouter(value));
                             _selectedProfileId = null; // Reset profile
                           }
                         },
                         validator: (v) => v == null ? "Required" : null,
                       ),
                       
                       const SizedBox(height: 20),
                       
                       const Text("Select Profile (Plan)", style: TextStyle(fontWeight: FontWeight.bold)),
                       const SizedBox(height: 8),
                       if (formData.isLoadingProfiles)
                          const LinearProgressIndicator()
                       else
                          DropdownButtonFormField<String>(
                            value: _selectedProfileId,
                            decoration: const InputDecoration(border: OutlineInputBorder()),
                            items: formData.profiles.map((profile) {
                              return DropdownMenuItem(
                                value: profile.id,
                                child: Text(profile.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedProfileId = value;
                                // Find plan name
                                final profile = formData.profiles.firstWhere((p) => p.id == value);
                                _selectedPlanName = profile.name;
                              });
                            },
                             validator: (v) => v == null ? "Required" : null,
                          ),

                       const SizedBox(height: 20),
                       
                       Row(
                         children: [
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 const Text("Price", style: TextStyle(fontWeight: FontWeight.bold)),
                                 const SizedBox(height: 8),
                                 TextFormField(
                                   controller: _priceController,
                                   keyboardType: TextInputType.number,
                                   decoration: const InputDecoration(
                                     prefixText: "\$ ",
                                     border: OutlineInputBorder(),
                                   ),
                                   validator: (v) => v!.isEmpty ? "Required" : null,
                                 ),
                               ],
                             ),
                           ),
                           const SizedBox(width: 16),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 const Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold)),
                                 const SizedBox(height: 8),
                                 TextFormField(
                                   controller: _quantityController,
                                   keyboardType: TextInputType.number,
                                   decoration: const InputDecoration(
                                     border: OutlineInputBorder(),
                                   ),
                                   validator: (v) => v!.isEmpty ? "Required" : null,
                                 ),
                               ],
                             ),
                           ),
                         ],
                       ),

                       const SizedBox(height: 20),
                       const Divider(),
                       const SizedBox(height: 10),

                       // Limit Type Selector
                       Row(
                         children: [
                           Expanded(
                             child: RadioListTile<String>(
                               title: const Text("Time Limit"),
                               value: "Time",
                               groupValue: _limitType,
                               onChanged: (v) => setState(() => _limitType = v!),
                               contentPadding: EdgeInsets.zero,
                             ),
                           ),
                           Expanded(
                             child: RadioListTile<String>(
                               title: const Text("Data Limit"),
                               value: "Data",
                               groupValue: _limitType,
                               onChanged: (v) => setState(() => _limitType = v!),
                               contentPadding: EdgeInsets.zero,
                             ),
                           ),
                         ],
                       ),

                       const SizedBox(height: 10),

                       // Limit Implementation
                       Row(
                         children: [
                           Expanded(
                             flex: 2,
                             child: TextFormField(
                               controller: _limitValueController,
                               keyboardType: TextInputType.number,
                               decoration: const InputDecoration(
                                 border: OutlineInputBorder(),
                                 labelText: "Value"
                               ),
                               validator: (v) => v!.isEmpty ? "Required" : null,
                             ),
                           ),
                           const SizedBox(width: 16),
                           Expanded(
                             flex: 1,
                             child: DropdownButtonFormField<String>(
                               value: _limitType == "Time" ? _timeUnit : _dataUnit,
                               decoration: const InputDecoration(border: OutlineInputBorder()),
                               items: _limitType == "Time" 
                                  ? ["Minutes", "Hours", "Days"].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList()
                                  : ["MB", "GB"].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                               onChanged: (value) {
                                 setState(() {
                                   if (_limitType == "Time") _timeUnit = value!;
                                   else _dataUnit = value!;
                                 });
                               },
                             ),
                           ),
                         ],
                       ),

                       const SizedBox(height: 40),
                       
                       SizedBox(
                         width: double.infinity,
                         height: 50,
                         child: ElevatedButton(
                           onPressed: () {
                             if (_formKey.currentState!.validate()) {
                                if (formData.selectedRouterId != null && _selectedProfileId != null) {
                                    
                                    int? duration;
                                    int? dataLimit;

                                    final limitVal = int.parse(_limitValueController.text);

                                    if (_limitType == "Time") {
                                      if (_timeUnit == "Minutes") duration = limitVal;
                                      else if (_timeUnit == "Hours") duration = limitVal * 60;
                                      else if (_timeUnit == "Days") duration = limitVal * 60 * 24;
                                    } else {
                                      if (_dataUnit == "MB") dataLimit = limitVal * 1024 * 1024;
                                      else if (_dataUnit == "GB") dataLimit = limitVal * 1024 * 1024 * 1024;
                                    }

                                    context.read<VoucherBloc>().add(GenerateVoucherEvent(
                                      routerId: formData.selectedRouterId!,
                                      profileId: _selectedProfileId!,
                                      planName: _selectedPlanName ?? "Standard",
                                      price: double.parse(_priceController.text),
                                      quantity: int.parse(_quantityController.text),
                                      duration: duration,
                                      dataLimit: dataLimit,
                                    ));
                                }
                             }
                           },
                           style: ElevatedButton.styleFrom(
                             backgroundColor: AppColors.primary,
                             foregroundColor: Colors.white,
                           ),
                           child: const Text("Generate Voucher"),
                         ),
                       )
                    ],
                  ),
                ),
              );
           }
           
           return const Center(child: Text("Initializing..."));
        },
      ),
    );
  }
}
