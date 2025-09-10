import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:mediscan_plus/Provider/Cubit/search_cubit.dart';
import 'package:mediscan_plus/main.dart';
import '../../Provider/Cubit/search_state.dart';

class AI_Assistant_Screen extends StatefulWidget {
  const AI_Assistant_Screen({super.key});

  @override
  State<AI_Assistant_Screen> createState() => _AI_Assistant_ScreenState();
}

class _AI_Assistant_ScreenState extends State<AI_Assistant_Screen> {
  bool isLoading = false;
  bool chatStarted = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: chatStarted ? _buildChatInterface() : _buildWelcomeScreen(),
    );
  }

  Widget _buildWelcomeScreen() {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/bot_light.png',
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "AI ASSISTANT",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: (){
                setState(() {
                  chatStarted = true;
                });
              },
              style: ButtonStyle(
                elevation: WidgetStateProperty.all(10),
                backgroundColor: WidgetStateProperty.all(AppTheme.primaryColor),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                )),
              ),
              child:
              Text("Start Chat", style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChatInterface() {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: "Can i take paracetamol in my prescription ?",
                prefixIcon: Icon(Icons.search),
                border:OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                )
              ),
            ),
            SizedBox(height: 20,),
            SizedBox(width:double.infinity,
            child: ElevatedButton(
                onPressed: (){
                  if(searchController.text.isNotEmpty)
                    {
                      context.read<SearchCubit>().getSearchResponse(query: searchController.text);
                    }
                },
                child: Text("Search")
            ),
            ),
            SizedBox(height:20),
            Expanded(
              child: BlocConsumer<SearchCubit,SearchState>
                (builder: (_,state){
                if(state is SearchLoadingState)
                  {
                    return Center(child: CircularProgressIndicator());
                  }
                if(state is SearchLoadedState)
                  {

                    return SingleChildScrollView(child: GptMarkdown(state.res));
                    // return AnimatedTextKit(animatedTexts: [
                    //   TyperAnimatedText(
                    //       state.res,
                    //     speed: Duration(milliseconds: 50),
                    //     textAlign: TextAlign.left
                    //   )
                    // ]);
                  }
                return Container();

              }, listener: (_,state){
                if(state is SearchErrorState)
                  {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${state.errorMsg}')));
                  }
              }
              ),
            )
          ],
        ),
      ),
    );
  }
  
  

}
