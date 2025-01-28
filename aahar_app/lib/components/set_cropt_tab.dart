import 'package:aahar_app/components/auth/get_farm_data_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetCropTab extends StatefulWidget {
  const SetCropTab({super.key});

  @override
  State<SetCropTab> createState() => _SetCropTabState();
}

class _SetCropTabState extends State<SetCropTab> {
  // Farming type controller
  final TextEditingController farmingTypeController = TextEditingController();
  // Save login data to SharedPreferences

  // Dynamic lists for crops and investments
  final List<Map<String, TextEditingController>> crops = [];
  final List<Map<String, dynamic>> investments = [];

  // Add a crop card with controllers
  void addCropCard() {
    setState(() {
      crops.add({
        "cropName": TextEditingController(),
        "plantingDate": TextEditingController(),
        "harvestingDate": TextEditingController(),
        "quantity": TextEditingController(),
        "amount": TextEditingController(),
      });
    });
  }

  // Add an investment card with controllers
  void addInvestmentCard() {
    setState(() {
      investments.add({
        "category": null, // Initial dropdown value
        "amount": TextEditingController(),
        "date": TextEditingController(),
        "description": TextEditingController(),
      });
    });
  }

  // Collect all data and create the JSON object
  Map<String, dynamic> getJsonResponse() {
    return {
      "farmingType": farmingTypeController.text,
      "crops": crops
          .map((crop) => {
                "cropName": crop["cropName"]!.text,
                "plantingDate": crop["plantingDate"]!.text,
                "harvestingDate": crop["harvestingDate"]!.text,
                "quantity": crop["quantity"]!.text,
                "amount": crop["amount"]!.text,
              })
          .toList(),
      "investments": investments
          .map((investment) => {
                "category": investment["category"],
                "amount": int.tryParse(investment["amount"]!.text) ?? 0,
                "date": investment["date"]!.text,
                "description": investment["description"]!.text,
              })
          .toList(),
    };
  }

  // Function to show a date picker and update the corresponding controller
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farming Type Section
          Text(
            "Farming Type",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: farmingTypeController,
            decoration: InputDecoration(
              labelText: "Enter farming type",
              border: OutlineInputBorder(),
              focusedBorder: Theme.of(context)
                  .inputDecorationTheme
                  .focusedBorder
                  ?.copyWith(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Crops Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Crops",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: addCropCard,
                icon: const Icon(Icons.add),
                label: const Text("Add Crop"),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          ...crops.map((crop) {
            final int index = crops.indexOf(crop);
            return Card(
              elevation: 2.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: crop["cropName"],
                      decoration: InputDecoration(
                        labelText: "Crop Name",
                        focusedBorder: Theme.of(context)
                            .inputDecorationTheme
                            .focusedBorder
                            ?.copyWith(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: crop["plantingDate"],
                      decoration: InputDecoration(
                        labelText: "Planting Date (YYYY-MM-DD)",
                        focusedBorder: Theme.of(context)
                            .inputDecorationTheme
                            .focusedBorder
                            ?.copyWith(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () =>
                              _selectDate(context, crop["plantingDate"]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: crop["harvestingDate"],
                      decoration: InputDecoration(
                        focusedBorder: Theme.of(context)
                            .inputDecorationTheme
                            .focusedBorder
                            ?.copyWith(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                        labelText: "Harvesting Date (YYYY-MM-DD)",
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () =>
                              _selectDate(context, crop["harvestingDate"]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: crop["quantity"],
                      decoration: InputDecoration(
                        focusedBorder: Theme.of(context)
                            .inputDecorationTheme
                            .focusedBorder
                            ?.copyWith(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                        labelText: "Quantity (e.g., 1000 kg)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: crop["amount"],
                      decoration: InputDecoration(
                        focusedBorder: Theme.of(context)
                            .inputDecorationTheme
                            .focusedBorder
                            ?.copyWith(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                        labelText: "Amount (e.g., 5000 USD)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            crops.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 24.0),

          // Investments Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Investments",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: addInvestmentCard,
                icon: const Icon(Icons.add),
                label: const Text("Add Investment"),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          ...investments.map((investment) {
            final int index = investments.indexOf(investment);
            return Card(
              elevation: 2.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: investment["category"]
                          ?.text, // Access the text property
                      onChanged: (String? newValue) {
                        setState(() {
                          investment["category"]?.text =
                              newValue ?? ""; // Update the text
                        });
                      },
                      items: [
                        "Seeds Fertilizers",
                        "Pesticides",
                        "Irrigation",
                        "Labor",
                        "Equipment Other"
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        focusedBorder: Theme.of(context)
                            .inputDecorationTheme
                            .focusedBorder
                            ?.copyWith(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                        labelText: "Category",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: investment["amount"],
                      decoration: InputDecoration(
                        focusedBorder: Theme.of(context)
                            .inputDecorationTheme
                            .focusedBorder
                            ?.copyWith(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                        labelText: "Amount",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: investment["date"],
                      decoration: InputDecoration(
                        focusedBorder: Theme.of(context)
                            .inputDecorationTheme
                            .focusedBorder
                            ?.copyWith(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                        labelText: "Date (YYYY-MM-DD)",
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () =>
                              _selectDate(context, investment["date"]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: investment["description"],
                      decoration: InputDecoration(
                        focusedBorder: Theme.of(context)
                            .inputDecorationTheme
                            .focusedBorder
                            ?.copyWith(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                        labelText: "Description",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            investments.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 24.0),

          // Submit Button
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final String accessToken = prefs.getString('accessToken') ?? '';

              final data = getJsonResponse();

              final GetFarmDataService getFarmData = GetFarmDataService();
              final response =
                  await getFarmData.postFarmData(data, accessToken);
              print(response);
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
