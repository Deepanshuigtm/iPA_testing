import 'dart:convert';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:easibite/screens/home_main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OnboardingScreen extends StatefulWidget {
  final UserProfile? user;  // Accept the UserProfile

  OnboardingScreen({Key? key, this.user});
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentStep = 0;
  Map<String, dynamic> userPreferences = {
    "dietary": [],
    "allergens": [],
    "spiceLevel": "Mild",
    "foodTemperature": "Hot",
    "notes": "",
  };

  final List<String> dietaryOptions = ["Halal", "Kosher", "Vegetarian", "Vegan"];
  final List<String> allergenOptions = [
    "Peanuts",
    "Tree Nuts",
    "Milk",
    "Eggs",
    "Fish",
    "Shellfish",
    "Soy",
    "Wheat",
    "Sesame",
  ];
  final List<String> spiceLevels = ["Mild", "Medium", "Spicy"];
  final List<String> foodTemperatures = ["Hot", "Cold"];

  @override
  void initState() {
    super.initState();

  }


  void _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save local preferences
      await prefs.setBool('isOnboarded', true);
      await prefs.setString('userPreferences', jsonEncode(userPreferences));

      // Prepare payload for the POST request
      final url = Uri.parse("http://3.101.68.145:7000/users");

      final payload = {
        "name": widget.user?.name ?? "John Doe",
        "emailid": widget.user?.email ?? "john.doe@example.com",
        "dietaryPreferences": userPreferences['dietary'] ?? [],
        "allergens": userPreferences['allergens'] ?? [],
        "spiceLevel": userPreferences['spiceLevel'] ?? "Medium",
        "foodTemperature": [userPreferences['foodTemperature'] ?? "Hot"],
        "additionalNotes": userPreferences['notes'] ?? "",
        "onboardingCompleted": true,
      };

      // Send POST request
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Preferences saved successfully!"),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeMain(user: widget.user)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save preferences: ${response.body}"),
          ),
        );
      }
    } catch (e) {
      print("Error saving preferences: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving preferences."),
        ),
      );
    }
  }


  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 5),
            Text(
              "Welcome to MenuSense",
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Text(
              "Let's personalize your dining \n experience",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Tell us about your dietary needs",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              "Select your dietary preferences",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            SizedBox(height: 20),
            ...dietaryOptions.map((option) {
              return SwitchListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                title: Text(
                  option,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  option == "Halal"
                      ? "Halal-certified food only"
                      : option == "Kosher"
                      ? "Follows kosher dietary laws"
                      : option == "Vegetarian"
                      ? "No meat products"
                      : "No animal products",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                activeColor: Colors.orange,
                value: userPreferences['dietary'].contains(option),
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      userPreferences['dietary'].add(option);
                    } else {
                      userPreferences['dietary'].remove(option);
                    }
                  });
                },
              );
            }).toList(),

          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    "Allergens",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Select any allergies or intolerances",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      userPreferences['allergens'].clear();
                    });
                  },
                  child: Text(
                    "Clear All",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: allergenOptions.map((option) {
                final isSelected = userPreferences['allergens'].contains(option);
                return ChoiceChip(
                  label: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.orange[700],
                  showCheckmark: false,
                  backgroundColor: Colors.grey[200],
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        userPreferences['allergens'].add(option);
                      } else {
                        userPreferences['allergens'].remove(option);
                      }
                    });
                  },
                );
              }).toList(),
            ),

          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "Additional Preferences",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Customize your experience",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),

            // Spice Level Preference
            Text(
              "Spice Level Preference",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: spiceLevels.map((level) {
                return ChoiceChip(
                  label: Text(
                    level,
                    style: TextStyle(
                      color: userPreferences['spiceLevel'] == level ? Colors.white : Colors.black,
                    ),
                  ),
                  selected: userPreferences['spiceLevel'] == level,
                  selectedColor: Colors.orange,
                  backgroundColor: Colors.grey[200],
                  showCheckmark: false, // Removes the tick icon
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        userPreferences['spiceLevel'] = level;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Food Temperature
            Text(
              "Food Temperature",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: foodTemperatures.map((temp) {
                return ChoiceChip(
                  label: Text(
                    temp,
                    style: TextStyle(
                      color: userPreferences['foodTemperature'] == temp ? Colors.white : Colors.black,
                    ),
                  ),
                  selected: userPreferences['foodTemperature'] == temp,
                  selectedColor: Colors.orange,
                  backgroundColor: Colors.grey[200],
                  showCheckmark: false, // Removes the tick icon
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        userPreferences['foodTemperature'] = temp;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Additional Notes
            Text(
              "Additional Notes",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: "Any other dietary requirements...",
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              onChanged: (value) {
                setState(() {
                  userPreferences['notes'] = value;
                });
              },
            ),

          ],
        );

      case 4:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "You're All\n",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Black color for "You're All"
                    ),
                  ),
                  TextSpan(
                    text: "Set!",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange, // Orange color for "Set!"
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Your profile is ready. Let's start finding\nsafe and delicious food options for you.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    "Your Profile Summary:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: userPreferences.entries.expand<Widget>((entry) {
                      if (entry.value != null && entry.value.toString().isNotEmpty) {
                        // Check if the value is a List
                        if (entry.value is List) {
                          return (entry.value as List).map<Widget>((item) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(

                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item.toString(), // Display each item in the list
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                              ),
                            );
                          });
                        } else {
                          // For non-list values
                          return [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(

                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                entry.value.toString(), // Display the single value
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ];
                        }
                      }
                      return []; // Return an empty list if the condition is not met
                    }).toList(), // Convert the Iterable<Widget> to a List<Widget>
                  ),

                ],
              ),
            ),
          ],
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Onboarding"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (currentStep + 1) / 5,
          ),
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 16.0, left: 12.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Step ${currentStep + 1} of 5"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 26.0),
                  child: _buildStepContent(),
                ),
              ],
            ),
          ),
          Spacer(), // Push the button down to center it in the remaining space
          ElevatedButton(
            onPressed: () {
              if (currentStep == 0) {
                setState(() {
                  currentStep++;
                });
              } else if (currentStep < 4) {
                setState(() {
                  currentStep++;
                });
              } else {
                _savePreferences();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 10),
            ),
            child: Text(
              currentStep == 0
                  ? "Get Started"
                  : currentStep == 3
                  ? "Done"
                  : currentStep == 4
                  ? "Start Exploring"
                  : "Continue",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Spacer(), // Push remaining space below the button
        ],
      )
    );
  }
}


