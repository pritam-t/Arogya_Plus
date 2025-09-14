import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

import '../../Provider/Assistant_Cubit/search_cubit.dart';
import '../../Provider/Assistant_Cubit/search_state.dart';

class AI_Assistant_Screen extends StatefulWidget {
  const AI_Assistant_Screen({super.key});

  @override
  State<AI_Assistant_Screen> createState() => _AI_Assistant_ScreenState();
}

class _AI_Assistant_ScreenState extends State<AI_Assistant_Screen> {
  bool chatStarted = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: chatStarted
          ? _buildChatInterface(screenW, screenH)
          : _buildWelcomeScreen(screenW, screenH),
    );
  }

  Widget _buildWelcomeScreen(double screenW, double screenH) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenW * 0.08),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bot Avatar
                Container(
                  padding: EdgeInsets.all(screenW * 0.05),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: screenW * 0.08,
                        spreadRadius: screenW * 0.015,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      'assets/images/bot_light.png',
                      width: screenW * 0.3,
                      height: screenW * 0.3,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: screenH * 0.05),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(screenW * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(screenW * 0.03),
                      ),
                      child: Icon(Icons.medical_services_outlined,
                          color: Colors.white, size: screenW * 0.06),
                    ),
                    SizedBox(width: screenW * 0.03),
                    Text("AI HEALTH",
                        style: TextStyle(
                          fontSize: screenW * 0.07,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        )),
                  ],
                ),
                Text("ASSISTANT",
                    style: TextStyle(
                      fontSize: screenW * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    )),
                SizedBox(height: screenH * 0.02),

                Text(
                  "Your personal healthcare companion.\nAsk me anything about your health!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenW * 0.04,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: screenH * 0.06),

                // Start Chat Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenW * 0.08),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: screenW * 0.05,
                        offset: Offset(0, screenH * 0.01),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => setState(() => chatStarted = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF667EEA),
                      padding: EdgeInsets.symmetric(
                          horizontal: screenW * 0.1,
                          vertical: screenH * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenW * 0.08),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: screenW * 0.05),
                        SizedBox(width: screenW * 0.03),
                        Text("Start Consultation",
                            style: TextStyle(
                                fontSize: screenW * 0.045,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenH * 0.04),

                // Feature Pills
                Wrap(
                  spacing: screenW * 0.03,
                  runSpacing: screenW * 0.03,
                  children: [
                    _buildFeaturePill("Medication Info", Icons.medication,
                        screenW, screenH),
                    _buildFeaturePill("Symptom Check",
                        Icons.health_and_safety, screenW, screenH),
                    _buildFeaturePill(
                        "Health Tips", Icons.tips_and_updates, screenW, screenH),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePill(
      String text, IconData icon, double screenW, double screenH) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: screenW * 0.04, vertical: screenH * 0.01),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(screenW * 0.05),
        border: Border.all(color: Colors.white54),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: screenW * 0.04, color: Colors.white),
          SizedBox(width: screenW * 0.015),
          Text(text,
              style: TextStyle(
                color: Colors.white,
                fontSize: screenW * 0.03,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }

  Widget _buildChatInterface(double screenW, double screenH) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: screenH * 0.001),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: BlocConsumer<SearchCubit, SearchState>(
                      builder: (_, state) {
                        if (state is SearchLoadingState) {
                          return _buildLoadingWidget(screenW, screenH);
                        }
                        if (state is SearchLoadedState) {
                          return _buildResponseWidget(
                              state.res, screenW, screenH);
                        }
                        return _buildEmptyState(screenW, screenH);
                      },
                      listener: (_, state) {
                        if (state is SearchErrorState) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${state.errorMsg}'),
                            backgroundColor: Colors.red.shade400,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(screenW * 0.03),
                            ),
                          ));
                        }
                      },
                    ),
                  ),
                  _buildInputArea(screenW, screenH),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(double screenW, double screenH) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(screenW * 0.05),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(screenW * 0.05),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: screenW * 0.05,
                  spreadRadius: screenW * 0.01,
                ),
              ],
            ),
            child: SizedBox(
              width: screenW * 0.08,
              height: screenW * 0.08,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF667EEA)),
                strokeWidth: 3,
              ),
            ),
          ),
          SizedBox(height: screenH * 0.025),
          Text("Analyzing your Issue...",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: screenW * 0.04,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildResponseWidget(
      String response, double screenW, double screenH) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(screenW * 0.05),
      child: Container(
        padding: EdgeInsets.all(screenW * 0.05),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenW * 0.05),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: screenW * 0.05,
              spreadRadius: screenW * 0.01,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(screenW * 0.015),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(screenW * 0.02),
                  ),
                  child: Icon(Icons.medical_information,
                      color: const Color(0xFF667EEA), size: screenW * 0.04),
                ),
                SizedBox(width: screenW * 0.02),
                Text("Health Assistant Response",
                    style: TextStyle(
                        fontSize: screenW * 0.035,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF667EEA))),
              ],
            ),
            SizedBox(height: screenH * 0.02),
            GptMarkdown(response),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(double screenW, double screenH) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenW * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(screenW * 0.05),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(screenW * 0.3),
              ),
              child: Image.asset(
                'assets/images/bot_light.png',
                width: screenW * 0.3,
                height: screenW * 0.3,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: screenH * 0.03),
            Text("Ask me anything!",
                style: TextStyle(
                    fontSize: screenW * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            SizedBox(height: screenH * 0.01),
            Text(
              "💡 Tip: Be specific about symptoms, medications, or health concerns for better assistance",
              style: TextStyle(
                  fontSize: screenW * 0.03,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(double screenW, double screenH) {
    return Container(
      padding: EdgeInsets.all(screenW * 0.05),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: screenW * 0.05,
              offset: const Offset(0, -2)),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(screenW * 0.07),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: TextField(
          controller: searchController,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => _sendMessage(),
          decoration: InputDecoration(
            hintText: "Can I take paracetamol with my prescription?",
            hintStyle:
            TextStyle(color: Colors.grey.shade500, fontSize: screenW * 0.04),
            prefixIcon: Padding(
              padding: EdgeInsets.all(screenW * 0.015),
              child: Image.asset(
                'assets/images/bot_light.png',
                height: screenW * 0.1,
                width: screenW * 0.1,
                fit: BoxFit.cover,
              ),
            ),
            suffixIcon: GestureDetector(
              onTap: _sendMessage,
              child: Container(
                margin: EdgeInsets.all(screenW * 0.02),
                padding: EdgeInsets.all(screenW * 0.02),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA),
                  borderRadius: BorderRadius.circular(screenW * 0.03),
                ),
                child:
                Icon(Icons.send_rounded, color: Colors.white, size: screenW * 0.05),
              ),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
                horizontal: screenW * 0.04, vertical: screenH * 0.015),
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    if (searchController.text.trim().isNotEmpty) {
      context
          .read<SearchCubit>()
          .getSearchResponse(query: searchController.text.trim());
      searchController.clear();
    }
  }
}
