import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/single_child_widget.dart' show SingleChildWidget;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

// ------------------- BACKGROUND CONTAINER -------------------

class BackgroundContainer extends StatelessWidget {
  const BackgroundContainer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFF48FB1), // Pink (e.g., Material Pink 300)
            Color(0xFFE1BEE7), // Lighter Purple (e.g., Material Purple 100)
            Color(0xFFCE93D8), // Light Purple (e.g., Material Purple 200)
            Color(0xFFB39DDB), // Lavender/Blueish Purple (e.g., Material DeepPurple 200)
            Color(0xFF9FA8DA), // Medium Blue-Purple (e.g., Material Indigo 200)
            Color(0xFFA5DFF0), // Light Sky Blue
            Color(0xFF81D4FA), // Sky Blue (e.g., Material LightBlue 200)
            Color(0xFF80CBC4), // Soft Teal (e.g., Material Teal 200)
            Color(0xFFA5D6A7), // Light Green (e.g., Material Green 200)
          ],
          stops: <double>[0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0],
        ),
      ),
      child: child,
    );
  }
}

// ------------------- MAIN APP -------------------

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<JournalData>(create: (_) => JournalData()),
          ChangeNotifierProvider<ScrapbookData>(create: (_) => ScrapbookData()),
          ChangeNotifierProvider<ProfileData>(create: (_) => ProfileData()), // Add ProfileData
        ],
        builder: (BuildContext context, Widget? child) {
          final ProfileData profileData = context.watch<ProfileData>();
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Memomuse',
            theme: ThemeData(
              primarySwatch: Colors.lightGreen,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFFFF44F),
                foregroundColor: Colors.black,
              ),
              textTheme: TextTheme(
                bodyMedium: GoogleFonts.robotoMono(fontSize: profileData.generalFontSize),
                labelLarge: GoogleFonts.robotoMono(fontSize: profileData.generalFontSize),
                headlineSmall: GoogleFonts.robotoMono(fontSize: profileData.generalFontSize + 4, fontWeight: FontWeight.bold),
                titleMedium: GoogleFonts.robotoMono(fontSize: profileData.generalFontSize + 2, fontWeight: FontWeight.bold),
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: Colors.teal,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
              ),
              textTheme: TextTheme(
                bodyMedium: GoogleFonts.robotoMono(fontSize: profileData.generalFontSize, color: Colors.white70),
                labelLarge: GoogleFonts.robotoMono(fontSize: profileData.generalFontSize, color: Colors.white),
                headlineSmall: GoogleFonts.robotoMono(fontSize: profileData.generalFontSize + 4, fontWeight: FontWeight.bold, color: Colors.white),
                titleMedium: GoogleFonts.robotoMono(fontSize: profileData.generalFontSize + 2, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            themeMode: profileData.appTheme, // Use theme from profile data
            home: const SignInPage(),
          );
        },
      ),
    );
  }
}

// ------------------- SIGN-IN PAGE -------------------

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (_formKey.currentState!.validate()) {
      // Simulate successful sign-in
      final ProfileData profileData = context.read<ProfileData>();
      profileData.updateProfileDetails(
        firstName: 'Guest', // Default for sign-in, could be retrieved from a real backend
        lastName: 'User',
        email: _emailController.text,
        dateOfBirth: null, // No DOB known from sign-in
        profilePhotoUrl: null, // No photo known from sign-in
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<Widget>(
          builder: (BuildContext context) => const MyHomePage(title: 'Memomuse'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text('Welcome',
            style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Memomuse',
                    style: GoogleFonts.robotoMono(
                        fontSize: 45, color: Colors.black87)),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    prefixIcon: const Icon(Icons.email),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  style: GoogleFonts.robotoMono(),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    prefixIcon: const Icon(Icons.lock),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                  style: GoogleFonts.robotoMono(),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _signIn,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA2D9CE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    textStyle: GoogleFonts.robotoMono(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute<Widget>(
                      builder: (BuildContext context) => const RegisterPage(),
                    ));
                  },
                  child: Text('Create New Account',
                      style: GoogleFonts.robotoMono(
                          fontSize: 16,
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------- REGISTER PAGE -------------------

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? _selectedDateOfBirth;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      // In a real app, you'd send this data to a backend
      // For this UI, we just simulate success and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully!', style: GoogleFonts.robotoMono()),
          backgroundColor: Colors.green,
        ),
      );

      final ProfileData profileData = context.read<ProfileData>();
      profileData.updateProfileDetails(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        dateOfBirth: _selectedDateOfBirth,
        profilePhotoUrl: null, // Default for new registration
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<Widget>(
          builder: (BuildContext context) => const MyHomePage(title: 'Memomuse'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text('Create Account',
            style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: topPadding, left: 32, right: 32, bottom: 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Join Memomuse',
                    style: GoogleFonts.robotoMono(
                        fontSize: 35, color: Colors.black87)),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    hintText: 'Enter your first name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    prefixIcon: const Icon(Icons.person),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                  style: GoogleFonts.robotoMono(),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    hintText: 'Enter your last name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    prefixIcon: const Icon(Icons.person_outline),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                  style: GoogleFonts.robotoMono(),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    prefixIcon: const Icon(Icons.email),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  style: GoogleFonts.robotoMono(),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Create a password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    prefixIcon: const Icon(Icons.lock),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                  style: GoogleFonts.robotoMono(),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.calendar_today, color: Colors.black54),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDateOfBirth == null
                              ? 'Date of Birth (Optional)'
                              : 'Date of Birth: ${DateFormat.yMMMd().format(_selectedDateOfBirth!)}',
                          style: GoogleFonts.robotoMono(
                              fontSize: 16,
                              color: _selectedDateOfBirth == null ? Colors.black54 : Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: _pickDateOfBirth,
                        child: Text(
                          _selectedDateOfBirth == null ? 'Select Date' : 'Change Date',
                          style: GoogleFonts.robotoMono(color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _register,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Register Account'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA2D9CE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    textStyle: GoogleFonts.robotoMono(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------- HOME PAGE -------------------

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  Future<void> _showFullCalendarAndNavigate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      Navigator.of(context).push(MaterialPageRoute<Widget>(
        builder: (BuildContext routeContext) => DailyOverviewPage(selectedDate: pickedDate),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text(title,
            style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold)),
        leading: IconButton( // Added leading icon for back option
          icon: const Icon(Icons.arrow_back, size: 30),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => const SignInPage(),
              ),
            );
          },
          tooltip: 'Back to Sign In',
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.calendar_month, size: 30),
            onPressed: () => _showFullCalendarAndNavigate(context),
            tooltip: 'View Calendar',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute<Widget>(
                builder: (BuildContext context) => const ProfilePage(),
              ));
            },
            tooltip: 'Profile',
          ),
          const SizedBox(width: 8), // Add some spacing
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Consumer<ProfileData>(
              builder: (BuildContext context, ProfileData profileData, Widget? child) {
                return Text(
                  'Hi ${profileData.firstName}!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87),
                );
              },
            ),
            const SizedBox(height: 40),
            // Weekly Calendar Display
            SizedBox(
              height: 100,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (BuildContext context, int index) {
                  final DateTime today = DateTime.now();
                  final DateTime date = today.subtract(Duration(days: today.weekday - 1)).add(Duration(days: index)); // Start from Monday
                  final bool isToday = date.day == today.day && date.month == today.month && date.year == today.year;
                  return DayCard(
                    date: date,
                    isToday: isToday,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute<Widget>(
                        builder: (BuildContext routeContext) => DailyOverviewPage(selectedDate: date),
                      ));
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute<Widget>(
                  builder: (BuildContext context) => const JournalPage(),
                ));
              },
              icon: const Icon(Icons.book),
              label: const Text('Start Journaling'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA2D9CE),
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: GoogleFonts.robotoMono(
                    fontSize: 20, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute<Widget>(
                  builder: (BuildContext context) => const ScrapbookingPage(),
                ));
              },
              icon: const Icon(Icons.photo),
              label: const Text('Start Scrapbooking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFADD8E6),
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: GoogleFonts.robotoMono(
                    fontSize: 20, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- DAY CARD WIDGET -------------------
class DayCard extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final VoidCallback onTap;

  const DayCard({
    required this.date,
    required this.isToday,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        width: 70,
        decoration: BoxDecoration(
          color: isToday ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isToday
              ? <BoxShadow>[
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              DateFormat.E().format(date), // Day of week (e.g., 'Mon')
              style: GoogleFonts.robotoMono(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isToday ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat.d().format(date), // Day number (e.g., '27')
              style: GoogleFonts.robotoMono(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isToday ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- DAILY OVERVIEW PAGE -------------------

class DailyOverviewPage extends StatelessWidget {
  const DailyOverviewPage({super.key, required this.selectedDate});
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          DateFormat.yMMMd().format(selectedDate),
          style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer2<JournalData, ScrapbookData>(
        builder: (BuildContext context, JournalData journalData, ScrapbookData scrapbookData, Widget? child) {
          // 1. Fetch the data for the selected date for BOTH providers
          final List<JournalEntry> dailyJournalEntries = journalData.getEntriesForDate(selectedDate);
          final List<ScrapbookPage> dailyScrapbookPages = scrapbookData.getPagesForDate(selectedDate);

          // 2. Check if there is ANY content to display
          final bool hasContent = dailyJournalEntries.isNotEmpty || dailyScrapbookPages.isNotEmpty;

          // --- For Debugging: You can check your console to see what's being loaded ---
          print('--- Daily Overview for ${DateFormat.yMd().format(selectedDate)} ---');
          print('Found ${dailyJournalEntries.length} journal entries.');
          print('Found ${dailyScrapbookPages.length} scrapbook pages.');
          // --------------------------------------------------------------------------

          return Padding(
            padding: EdgeInsets.only(top: topPadding, left: 16, right: 16, bottom: 16),
            child: hasContent
                ? ListView(
              children: <Widget>[
                // 3. Conditionally display the Journal Entries section
                if (dailyJournalEntries.isNotEmpty) ...<Widget>[
                  Text('Journal Entries', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  ...dailyJournalEntries.map<Widget>((JournalEntry entry) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: const Color(0xFFDCEDC8),
                    child: ListTile(
                      title: Text(entry.title, style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold)),
                      subtitle: Text(entry.content, style: GoogleFonts.robotoMono(), maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: Text(DateFormat.jm().format(entry.timestamp), style: GoogleFonts.robotoMono(fontSize: 12)),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute<Widget>(
                          builder: (BuildContext routeContext) => JournalEntryEditorPage(entry: entry),
                        ));
                      },
                    ),
                  )).toList(),
                  const SizedBox(height: 20),
                ],

                // 4. Conditionally display the Scrapbook Pages section
                if (dailyScrapbookPages.isNotEmpty) ...<Widget>[
                  Text('Scrapbook Pages', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  ...dailyScrapbookPages.map((page) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: const Color(0xFFE3F2FD),
                    child: ListTile(
                      leading: const Icon(Icons.photo_album_outlined, color: Colors.blueGrey),
                      title: Text(
                        'Page created at ${DateFormat.jm().format(page.creationDate)}',
                        style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${page.photos.length} photos, ${page.stickers.length} stickers',
                        style: GoogleFonts.robotoMono(),
                      ),
                      onTap: () {
                        context.read<ScrapbookData>().goToPageById(page.id);
                        Navigator.of(context).push(MaterialPageRoute<Widget>(
                          builder: (BuildContext context) => const ScrapbookingPage(),
                        ));
                      },
                    ),
                  )).toList(),
                  const SizedBox(height: 20),
                ],
              ],
            )
                : Center( // 5. If no content, show the message
              child: Text(
                'No work has been done for this date.',
                style: GoogleFonts.robotoMono(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}
// ------------------- JOURNAL DATA -------------------

class JournalData extends ChangeNotifier {
  final List<JournalEntry> _entries = <JournalEntry>[];

  JournalData() {
    _loadEntries();
  }

  List<JournalEntry> get entries => List<JournalEntry>.unmodifiable(_entries);

  Future<void> _loadEntries() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('journalEntries');
    if (jsonString != null) {
      final List<dynamic> list = json.decode(jsonString) as List<dynamic>;
      _entries.clear();
      _entries.addAll(list
          .map<JournalEntry>(
              (dynamic e) => JournalEntry.fromJson(e as Map<String, dynamic>))
          .toList());
      _entries.sort((JournalEntry a, JournalEntry b) =>
          a.timestamp.compareTo(b.timestamp));
      notifyListeners();
    }
  }

  Future<void> _saveEntries() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(
        _entries.map<Map<String, dynamic>>((JournalEntry e) => e.toJson()).toList());
    await prefs.setString('journalEntries', jsonString);
  }

  void addEntry({
    required String title,
    required String content,
    required DateTime timestamp,
    double? fontSize,
    String? fontFamily,
  }) {
    final JournalEntry entry = JournalEntry(
        id: DateTime.now().toIso8601String(),
        title: title,
        content: content,
        timestamp: timestamp,
        fontSize: fontSize,
        fontFamily: fontFamily);
    _entries.add(entry);
    _entries.sort((JournalEntry a, JournalEntry b) =>
        a.timestamp.compareTo(b.timestamp));
    notifyListeners();
    _saveEntries();
  }

  void updateEntry(JournalEntry entry) {
    final int index = _entries.indexWhere((JournalEntry e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
      _entries.sort((JournalEntry a, JournalEntry b) =>
          a.timestamp.compareTo(b.timestamp));
      notifyListeners();
      _saveEntries();
    }
  }

  void deleteEntry(JournalEntry entry) {
    _entries.removeWhere((JournalEntry e) => e.id == entry.id);
    notifyListeners();
    _saveEntries();
  }

  List<JournalEntry> getEntriesForDate(DateTime date) {
    return _entries.where((JournalEntry e) {
      return e.timestamp.year == date.year &&
          e.timestamp.month == date.month &&
          e.timestamp.day == date.day;
    }).toList();
  }
}

// ------------------- JOURNAL ENTRY MODEL -------------------

class JournalEntry {
  String id;
  String title;
  String content;
  DateTime timestamp;
  double? fontSize;
  String? fontFamily;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    this.fontSize,
    this.fontFamily,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'fontSize': fontSize,
    'fontFamily': fontFamily,
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    fontSize: (json['fontSize'] as num?)?.toDouble(),
    fontFamily: json['fontFamily'] as String?,
  );
}

// ------------------- JOURNAL BOOK CARD WIDGET -------------------

class JournalBookCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;

  const JournalBookCard({
    required this.entry,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color(0xFFDCEDC8),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black26, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: Icon(Icons.menu_book, size: 36, color: Colors.brown[600]),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  entry.title,
                  style: GoogleFonts.robotoMono(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat.yMMMd().format(entry.timestamp),
                style: GoogleFonts.robotoMono(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------- JOURNAL PAGE -------------------

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text('Your Journal',
            style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<JournalData>(
        builder: (BuildContext context, JournalData journalData, Widget? child) {
          final double topPadding =
              MediaQuery.of(context).padding.top + kToolbarHeight;

          if (journalData.entries.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: Center(
                  child: Text('No entries yet!',
                      style: GoogleFonts.robotoMono(fontSize: 18))),
            );
          }

          return Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: journalData.entries.length,
              itemBuilder: (BuildContext context, int index) {
                final JournalEntry entry = journalData.entries[index];
                return JournalBookCard(
                  entry: entry,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute<Widget>(
                      builder: (BuildContext routeContext) =>
                          JournalEntryEditorPage(entry: entry),
                    ));
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute<Widget>(
            builder: (BuildContext routeContext) => const JournalEntryEditorPage(),
          ));
        },
        backgroundColor: const Color(0xFFA2D9CE),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class JournalEntryEditorPage extends StatefulWidget {
  const JournalEntryEditorPage({super.key, this.entry});
  final JournalEntry? entry;
  @override
  State<JournalEntryEditorPage> createState() => _JournalEntryEditorPageState();
}

class _JournalEntryEditorPageState extends State<JournalEntryEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late DateTime _selectedDate;
  late double _selectedFontSize;
  late String _selectedFontFamily;

  static const List<String> _availableFonts = <String>[
    'Roboto Mono',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Merriweather',
    'Playfair Display',
    'Dancing Script',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController =
        TextEditingController(text: widget.entry?.content ?? '');
    _selectedDate = widget.entry?.timestamp ?? DateTime.now();
    _selectedFontSize = widget.entry?.fontSize ?? 16.0;
    _selectedFontFamily = widget.entry?.fontFamily ?? _availableFonts.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    final String title = _titleController.text;
    final String content = _contentController.text;
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please fill all fields',
              style: GoogleFonts.robotoMono())));
      return;
    }
    final JournalEntry entry = JournalEntry(
        id: widget.entry?.id ?? DateTime.now().toIso8601String(),
        title: title,
        content: content,
        timestamp: _selectedDate,
        fontSize: _selectedFontSize,
        fontFamily: _selectedFontFamily);
    final JournalData data = context.read<JournalData>();
    if (widget.entry == null) {
      data.addEntry(
        title: title,
        content: content,
        timestamp: _selectedDate,
        fontSize: _selectedFontSize,
        fontFamily: _selectedFontFamily,
      );
    } else {
      data.updateEntry(entry);
    }
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.entry != null;
    final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    final TextStyle contentTextStyle = GoogleFonts.getFont(
      _selectedFontFamily,
      fontSize: _selectedFontSize,
    );

    final TextStyle titleTextStyle = GoogleFonts.getFont(
      _selectedFontFamily,
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text(isEditing ? 'Edit Entry' : 'New Entry',
            style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: topPadding, left: 32, right: 32, bottom: 32),
        child: ListView(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  fillColor: Colors.white,
                  filled: true),
              style: titleTextStyle,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  fillColor: Colors.white,
                  filled: true),
              style: contentTextStyle,
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                    child: Text('Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                        style: GoogleFonts.robotoMono())),
                TextButton(
                    onPressed: _pickDate,
                    child: Text('Select Date', style: GoogleFonts.robotoMono())),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Content Font Size:', style: GoogleFonts.robotoMono()),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  onPressed: () {
                    setState(() {
                      _selectedFontSize = (_selectedFontSize - 1.0).clamp(10.0, 30.0);
                    });
                  },
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    _selectedFontSize.toStringAsFixed(0),
                    style: GoogleFonts.robotoMono(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: () {
                    setState(() {
                      _selectedFontSize = (_selectedFontSize + 1.0).clamp(10.0, 30.0);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Font Family:', style: GoogleFonts.robotoMono()),
                PopupMenuButton<String>(
                  initialValue: _selectedFontFamily,
                  onSelected: (String newValue) {
                    setState(() {
                      _selectedFontFamily = newValue;
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return _availableFonts.map<PopupMenuItem<String>>((String fontName) {
                      return PopupMenuItem<String>(
                        value: fontName,
                        child: Text(
                          fontName,
                          style: GoogleFonts.getFont(fontName, fontSize: 16),
                        ),
                      );
                    }).toList();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          _selectedFontFamily,
                          style: GoogleFonts.getFont(_selectedFontFamily, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_drop_down, size: 24, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA2D9CE),
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text('Save Entry', style: GoogleFonts.robotoMono(fontSize: 18)),
            ),
            if (isEditing) ...<Widget>[
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  context.read<JournalData>().deleteEntry(widget.entry!);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: Text('Delete Entry', style: GoogleFonts.robotoMono(fontSize: 18, color: Colors.white)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// Helper to parse DateTime from id string for ScrapbookPhoto and Sticker
DateTime _parseDateFromId(String id) {
  try {
    return DateTime.parse(id);
  } catch (e) {
    // Fallback if id is not a valid ISO 8601 string, though it should be if generated by DateTime.now().toIso8601String()
    return DateTime.now(); // Return current date as a fallback
  }
}
// ------------------- SCRAPBOOK PAGE MODEL -------------------

class ScrapbookPage {
  final String id;
  DateTime creationDate; // New field for the date
  List<ScrapbookPhoto> photos;
  List<Sticker> stickers;

  ScrapbookPage({
    required this.id,
    required this.creationDate, // Make date required
    List<ScrapbookPhoto>? photos,
    List<Sticker>? stickers,
  })  : photos = photos ?? [],
        stickers = stickers ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'creationDate': creationDate.toIso8601String(), // Save the date
    'photos': photos.map((p) => p.toJson()).toList(),
    'stickers': stickers.map((s) => s.toJson()).toList(),
  };

  factory ScrapbookPage.fromJson(Map<String, dynamic> json) {
    // This logic ensures that old data without a 'creationDate' field can still be loaded
    final DateTime date = json.containsKey('creationDate')
        ? DateTime.parse(json['creationDate'] as String)
        : _parseDateFromId(json['id'] as String);

    return ScrapbookPage(
      id: json['id'] as String,
      creationDate: date, // Load the date
      photos: (json['photos'] as List<dynamic>)
          .map((e) => ScrapbookPhoto.fromJson(e as Map<String, dynamic>))
          .toList(),
      stickers: (json['stickers'] as List<dynamic>)
          .map((e) => Sticker.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
// ------------------- SCRAPBOOK PHOTO MODEL -------------------

class ScrapbookPhoto {
  final String id;
  final String url;
  final String? caption;
  double top;
  double left;
  double scale;
  double rotation;

  ScrapbookPhoto({
    required this.id,
    required this.url,
    this.caption,
    required this.top,
    required this.left,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'caption': caption,
    'top': top,
    'left': left,
    'scale': scale,
    'rotation': rotation,
  };

  factory ScrapbookPhoto.fromJson(Map<String, dynamic> json) => ScrapbookPhoto(
    id: json['id'] as String,
    url: json['url'] as String,
    caption: json['caption'] as String?,
    top: (json['top'] as num).toDouble(),
    left: (json['left'] as num).toDouble(),
    scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
    rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
  );
}

// ------------------- STICKER MODEL -------------------

class Sticker {
  final String id;
  final String url;
  double top;
  double left;
  double scale;

  Sticker({
    required this.id,
    required this.url,
    required this.top,
    required this.left,
    this.scale = 1.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'top': top,
    'left': left,
    'scale': scale,
  };

  factory Sticker.fromJson(Map<String, dynamic> json) => Sticker(
    id: json['id'] as String,
    url: json['url'] as String,
    top: (json['top'] as num).toDouble(),
    left: (json['left'] as num).toDouble(),
    scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
  );
}

// ------------------- SCRAPBOOK DATA -------------------

class ScrapbookData extends ChangeNotifier {
  final List<ScrapbookPage> _pages = <ScrapbookPage>[];
  int _currentPageIndex = 0;

  ScrapbookData() {
    _loadData();
  }

  // Public accessors
  List<ScrapbookPage> get pages => List<ScrapbookPage>.unmodifiable(_pages);
  int get currentPageIndex => _currentPageIndex;
  int get pageCount => _pages.length;
  ScrapbookPage? get currentPage => pageCount > 0 ? _pages[_currentPageIndex] : null;

  // --- Data Persistence ---
  Future<void> _loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('scrapbookPages');

    if (jsonString != null) {
      final List<dynamic> list = json.decode(jsonString) as List<dynamic>;
      _pages.clear();
      _pages.addAll(list
          .map<ScrapbookPage>((dynamic e) => ScrapbookPage.fromJson(e as Map<String, dynamic>))
          .toList());
    }

    // Ensure there is at least one page
    if (_pages.isEmpty) {
      final DateTime now = DateTime.now();
      _pages.add(ScrapbookPage(id: now.toIso8601String(), creationDate: now));
    }
    _currentPageIndex = 0; // Start at the first page
    notifyListeners();
  }

  Future<void> _saveData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(
        _pages.map<Map<String, dynamic>>((ScrapbookPage p) => p.toJson()).toList());
    await prefs.setString('scrapbookPages', jsonString);
  }

  // --- Page Management ---
  void addPage() {
    final DateTime now = DateTime.now();
    // Add the new page with a creation date
    _pages.add(ScrapbookPage(id: now.toIso8601String(), creationDate: now));
    _currentPageIndex = _pages.length - 1; // Go to the new page
    notifyListeners();
    _saveData();
  }

  void deleteCurrentPage() {
    if (pageCount > 1) { // Prevent deleting the last page
      _pages.removeAt(_currentPageIndex);
      if (_currentPageIndex >= _pages.length) {
        _currentPageIndex = _pages.length - 1;
      }
      notifyListeners();
      _saveData();
    }
  }

  void goToPage(int index) {
    if (index >= 0 && index < _pages.length) {
      _currentPageIndex = index;
      notifyListeners();
    }
  }

  // New method to navigate to a page by its ID
  void goToPageById(String pageId) {
    final int index = _pages.indexWhere((p) => p.id == pageId);
    if (index != -1) {
      _currentPageIndex = index;
      notifyListeners();
    }
  }

  // New method to update the date of the current page
  void updateCurrentPageDate(DateTime newDate) {
    if (currentPage != null) {
      final DateTime oldDate = currentPage!.creationDate;
      // Preserve the time, only change the year, month, and day
      currentPage!.creationDate = DateTime(
        newDate.year,
        newDate.month,
        newDate.day,
        oldDate.hour,
        oldDate.minute,
        oldDate.second,
      );
      notifyListeners();
      _saveData();
    }
  }


  // --- Item Management (operates on the current page) ---
  void addPhotoToCurrentPage(String url) {
    currentPage?.photos.add(ScrapbookPhoto(
      id: DateTime.now().toIso8601String(),
      url: url,
      top: 100.0,
      left: 100.0,
    ));
    notifyListeners();
    _saveData();
  }

  void updatePhotoOnCurrentPage(ScrapbookPhoto photo) {
    final int index = currentPage?.photos.indexWhere((ScrapbookPhoto p) => p.id == photo.id) ?? -1;
    if (index != -1) {
      currentPage?.photos[index] = photo;
      notifyListeners();
      _saveData();
    }
  }

  void deletePhotoFromCurrentPage(ScrapbookPhoto photo) {
    currentPage?.photos.removeWhere((ScrapbookPhoto p) => p.id == photo.id);
    notifyListeners();
    _saveData();
  }

  void addStickerToCurrentPage(String url) {
    currentPage?.stickers.add(Sticker(
      id: DateTime.now().toIso8601String(),
      url: url,
      top: 100.0,
      left: 100.0,
    ));
    notifyListeners();
    _saveData();
  }

  void updateStickerOnCurrentPage(Sticker sticker) {
    final int index = currentPage?.stickers.indexWhere((Sticker s) => s.id == sticker.id) ?? -1;
    if (index != -1) {
      currentPage?.stickers[index] = sticker;
      notifyListeners();
      _saveData();
    }
  }

  void deleteStickerFromCurrentPage(Sticker sticker) {
    currentPage?.stickers.removeWhere((Sticker s) => s.id == sticker.id);
    notifyListeners();
    _saveData();
  }

  // --- Data Filtering for Daily Overview ---
  // This new method finds pages by date, replacing the old item-based functions
  List<ScrapbookPage> getPagesForDate(DateTime date) {
    return _pages.where((ScrapbookPage p) {
      return p.creationDate.year == date.year &&
          p.creationDate.month == date.month &&
          p.creationDate.day == date.day;
    }).toList();
  }
}
// ------------------- DRAGGABLE PHOTO WIDGET -------------------

class DraggablePhoto extends StatefulWidget {
  const DraggablePhoto({
    required this.photo,
    super.key,
  });

  final ScrapbookPhoto photo;

  @override
  State<DraggablePhoto> createState() => _DraggablePhotoState();
}

class _DraggablePhotoState extends State<DraggablePhoto> {
  bool _isInteracting = false;
  late double _initialScale;

  @override
  void initState() {
    super.initState();
    _initialScale = widget.photo.scale;
  }

  void _onPhotoTap() {
    Navigator.of(context).push(MaterialPageRoute<Widget>(
      builder: (BuildContext routeContext) => PhotoViewPage(photo: widget.photo),
    ));
  }

  void _onPhotoLongPress() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete Photo', style: GoogleFonts.robotoMono()),
          content: Text('Are you sure you want to delete this photo?', style: GoogleFonts.robotoMono()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: GoogleFonts.robotoMono(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                context.read<ScrapbookData>().deletePhotoFromCurrentPage(widget.photo);
                Navigator.of(dialogContext).pop();
              },
              child: Text('Delete', style: GoogleFonts.robotoMono(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _isInteracting = true;
      widget.photo.top += details.delta.dy;
      widget.photo.left += details.delta.dx;
    });
    context.read<ScrapbookData>().updatePhotoOnCurrentPage(widget.photo);
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isInteracting = false;
      _initialScale = widget.photo.scale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.photo.top,
      left: widget.photo.left,
      child: Transform.rotate(
        angle: widget.photo.rotation,
        child: GestureDetector(
          onTap: _onPhotoTap,
          onLongPress: _onPhotoLongPress,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                width: 150 * widget.photo.scale,
                height: 150 * widget.photo.scale,
                child: Hero(
                  tag: widget.photo.id,
                  child: Image.network(
                    widget.photo.url,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (_isInteracting) ...<Widget>[
                Positioned(
                  top: -10,
                  left: -10,
                  child: _buildHandle(
                    onPanUpdate: (DragUpdateDetails details) {
                      setState(() {
                        final double newScale = _initialScale - (details.delta.dx / 150);
                        widget.photo.scale = newScale.clamp(0.5, 3.0);
                        widget.photo.left += details.delta.dx;
                        widget.photo.top += details.delta.dy;
                      });
                      context.read<ScrapbookData>().updatePhotoOnCurrentPage(widget.photo);
                    },
                  ),
                ),
                Positioned(
                  top: -10,
                  right: -10,
                  child: _buildHandle(
                    onPanUpdate: (DragUpdateDetails details) {
                      setState(() {
                        final double newScale = _initialScale + (details.delta.dx / 150);
                        widget.photo.scale = newScale.clamp(0.5, 3.0);
                        widget.photo.top += details.delta.dy;
                      });
                      context.read<ScrapbookData>().updatePhotoOnCurrentPage(widget.photo);
                    },
                  ),
                ),
                Positioned(
                  bottom: -10,
                  left: -10,
                  child: _buildHandle(
                    onPanUpdate: (DragUpdateDetails details) {
                      setState(() {
                        final double newScale = _initialScale - (details.delta.dx / 150);
                        widget.photo.scale = newScale.clamp(0.5, 3.0);
                        widget.photo.left += details.delta.dx;
                      });
                      context.read<ScrapbookData>().updatePhotoOnCurrentPage(widget.photo);
                    },
                  ),
                ),
                Positioned(
                  bottom: -10,
                  right: -10,
                  child: _buildHandle(
                    onPanUpdate: (DragUpdateDetails details) {
                      setState(() {
                        final double newScale = _initialScale + (details.delta.dx / 150);
                        widget.photo.scale = newScale.clamp(0.5, 3.0);
                      });
                      context.read<ScrapbookData>().updatePhotoOnCurrentPage(widget.photo);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle({required GestureDragUpdateCallback onPanUpdate}) {
    return GestureDetector(
      onPanUpdate: onPanUpdate,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.lightGreen,
          border: Border.all(color: Colors.white, width: 2),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ------------------- DRAGGABLE STICKER WIDGET -------------------

class DraggableSticker extends StatefulWidget {
  const DraggableSticker({
    required this.sticker,
    super.key,
  });

  final Sticker sticker;

  @override
  State<DraggableSticker> createState() => _DraggableStickerState();
}

class _DraggableStickerState extends State<DraggableSticker> {
  bool _isInteracting = false;
  late double _initialScale;

  @override
  void initState() {
    super.initState();
    _initialScale = widget.sticker.scale;
  }

  void _onStickerLongPress() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete Sticker', style: GoogleFonts.robotoMono()),
          content: Text('Are you sure you want to delete this sticker?', style: GoogleFonts.robotoMono()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: GoogleFonts.robotoMono(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                context.read<ScrapbookData>().deleteStickerFromCurrentPage(widget.sticker);(widget.sticker);
                Navigator.of(dialogContext).pop();
              },
              child: Text('Delete', style: GoogleFonts.robotoMono(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _isInteracting = true;
      widget.sticker.top += details.delta.dy;
      widget.sticker.left += details.delta.dx;
    });
    context.read<ScrapbookData>().updateStickerOnCurrentPage(widget.sticker);
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isInteracting = false;
      _initialScale = widget.sticker.scale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.sticker.top,
      left: widget.sticker.left,
      child: GestureDetector(
        onLongPress: _onStickerLongPress,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            SizedBox(
              width: 100 * widget.sticker.scale,
              height: 100 * widget.sticker.scale,
              child: Image.network(
                widget.sticker.url,
                fit: BoxFit.contain,
              ),
            ),
            if (_isInteracting) ...<Widget>[
              // Top-Left Handle
              Positioned(
                top: -10,
                left: -10,
                child: _buildHandle(
                  onPanUpdate: (DragUpdateDetails details) {
                    setState(() {
                      final double newScale = _initialScale - (details.delta.dx / 100);
                      widget.sticker.scale = newScale.clamp(0.5, 3.0);
                      widget.sticker.left += details.delta.dx;
                      widget.sticker.top += details.delta.dy;
                    });
                    context.read<ScrapbookData>().updateStickerOnCurrentPage(widget.sticker);
                  },
                ),
              ),
              // Top-Right Handle
              Positioned(
                top: -10,
                right: -10,
                child: _buildHandle(
                  onPanUpdate: (DragUpdateDetails details) {
                    setState(() {
                      final double newScale = _initialScale + (details.delta.dx / 100);
                      widget.sticker.scale = newScale.clamp(0.5, 3.0);
                      widget.sticker.top += details.delta.dy;
                    });
                    context.read<ScrapbookData>().updateStickerOnCurrentPage(widget.sticker);
                  },
                ),
              ),
              // Bottom-Left Handle
              Positioned(
                bottom: -10,
                left: -10,
                child: _buildHandle(
                  onPanUpdate: (DragUpdateDetails details) {
                    setState(() {
                      final double newScale = _initialScale - (details.delta.dx / 100);
                      widget.sticker.scale = newScale.clamp(0.5, 3.0);
                      widget.sticker.left += details.delta.dx;
                    });
                    context.read<ScrapbookData>().updateStickerOnCurrentPage(widget.sticker);
                  },
                ),
              ),
              // Bottom-Right Handle
              Positioned(
                bottom: -10,
                right: -10,
                child: _buildHandle(
                  onPanUpdate: (DragUpdateDetails details) {
                    setState(() {
                      final double newScale = _initialScale + (details.delta.dx / 100);
                      widget.sticker.scale = newScale.clamp(0.5, 3.0);
                    });
                    context.read<ScrapbookData>().updateStickerOnCurrentPage(widget.sticker);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHandle({required GestureDragUpdateCallback onPanUpdate}) {
    return GestureDetector(
      onPanUpdate: onPanUpdate,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.lightGreen,
          border: Border.all(color: Colors.white, width: 2),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ------------------- GALLERY PAGE -------------------

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final List<String> _photoUrls = <String>[
    'https://images.unsplash.com/photo-1465146344425-f00d5f5c8f07?q=80&w=1176&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1529419412599-7bb870e11810?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1533158326339-7f3cf2404354?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGFydHxlbnwwfHwwfHx8MA%3D%3D',
    'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTR8fGZvb2R8ZW58MHx8MHx8fDA%3D',
  ];

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text('Photo Gallery', style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _photoUrls.length,
          itemBuilder: (BuildContext context, int index) {
            final String url = _photoUrls[index];
            return GestureDetector(
              onTap: () {
                context.read<ScrapbookData>().addPhotoToCurrentPage(url);
                Navigator.of(context).pop();
              },
              child: Image.network(
                url,
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ------------------- STICKER GALLERY PAGE -------------------

class StickerGalleryPage extends StatelessWidget {
  const StickerGalleryPage({super.key});

  final List<String> _stickerUrls = const <String>[
    'https://cdn-icons-png.flaticon.com/256/7155/7155888.png',
    'https://cdn-icons-png.flaticon.com/256/5795/5795293.png',
    'https://cdn-icons-png.flaticon.com/256/10338/10338049.png',
    'https://cdn-icons-png.flaticon.com/256/5483/5483590.png',
  ];

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text('Sticker Gallery', style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: _stickerUrls.length,
          itemBuilder: (BuildContext context, int index) {
            final String url = _stickerUrls[index];
            return GestureDetector(
              onTap: () {
                context.read<ScrapbookData>().addStickerToCurrentPage(url);
                Navigator.of(context).pop();
              },
              child: Image.network(
                url,
                fit: BoxFit.contain,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ------------------- PHOTO VIEW PAGE -------------------

class PhotoViewPage extends StatelessWidget {
  const PhotoViewPage({required this.photo, super.key});
  final ScrapbookPhoto photo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Center(
        child: Hero(
          tag: photo.id,
          child: Image.network(
            photo.url,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// ------------------- SCRAPBOOKING PAGE -------------------

class ScrapbookingPage extends StatelessWidget {
  const ScrapbookingPage({super.key});

  // Helper method to show the date picker dialog
  Future<void> _pickNewDate(BuildContext context, ScrapbookData data) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: data.currentPage!.creationDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      data.updateCurrentPageDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate padding to position the date below the app bar
    final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;
    const String backgroundImageUrl =
        'https://images.unsplash.com/photo-1601662528567-526cd06f6582?q=80&w=715&auto=format&fit=crop&ixlib-rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Consumer<ScrapbookData>(
          builder: (context, scrapbookData, child) {
            return Text(
              'Page ${scrapbookData.currentPageIndex + 1} of ${scrapbookData.pageCount}',
              style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () {
              context.read<ScrapbookData>().addPage();
            },
            tooltip: 'Add a new page',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever_outlined),
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: Text('Delete Page', style: GoogleFonts.robotoMono()),
                    content: Text('Are you sure you want to delete this page?', style: GoogleFonts.robotoMono()),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text('Cancel', style: GoogleFonts.robotoMono(color: Colors.black)),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<ScrapbookData>().deleteCurrentPage();
                          Navigator.of(dialogContext).pop();
                        },
                        child: Text('Delete', style: GoogleFonts.robotoMono(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            },
            tooltip: 'Delete current page',
          ),
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute<Widget>(
                builder: (BuildContext context) => const StickerGalleryPage(),
              ));
            },
            tooltip: 'Add a sticker',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(backgroundImageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Consumer<ScrapbookData>(
          builder: (BuildContext context, ScrapbookData scrapbookData, Widget? child) {
            final ScrapbookPage? currentPage = scrapbookData.currentPage;
            if (currentPage == null) {
              return Center(child: Text('No pages available.', style: GoogleFonts.robotoMono()));
            }

            return Stack(
              children: <Widget>[
                // Display photos and stickers
                ...currentPage.photos.map((ScrapbookPhoto photo) {
                  return DraggablePhoto(key: Key(photo.id), photo: photo);
                }).toList(),
                ...currentPage.stickers.map((Sticker sticker) {
                  return DraggableSticker(key: Key(sticker.id), sticker: sticker);
                }).toList(),

                // Positioned widget to show and edit the date
                Positioned(
                  top: topPadding, // Position below the AppBar
                  left: 16,
                  child: GestureDetector(
                    onTap: () => _pickNewDate(context, scrapbookData),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.edit_calendar, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat.yMMMd().format(currentPage.creationDate),
                            style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Consumer<ScrapbookData>(
        builder: (context, scrapbookData, child) {
          return BottomAppBar(
            color: Colors.transparent,
            elevation: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: scrapbookData.currentPageIndex > 0
                      ? () => scrapbookData.goToPage(scrapbookData.currentPageIndex - 1)
                      : null,
                  tooltip: 'Previous Page',
                ),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute<Widget>(
                      builder: (BuildContext context) => const GalleryPage(),
                    ));
                  },
                  backgroundColor: const Color(0xFFADD8E6),
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add_photo_alternate),
                  tooltip: 'Add a photo',
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  onPressed: scrapbookData.currentPageIndex < scrapbookData.pageCount - 1
                      ? () => scrapbookData.goToPage(scrapbookData.currentPageIndex + 1)
                      : null,
                  tooltip: 'Next Page',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
// ------------------- PROFILE DATA -------------------

class ProfileData extends ChangeNotifier {
  String _firstName;
  String _lastName;
  String _email;
  DateTime? _dateOfBirth;
  String? _profilePhotoUrl;
  ThemeMode _appTheme;
  double _generalFontSize;

  ProfileData({
    String firstName = 'Guest',
    String lastName = '',
    String email = '',
    DateTime? dateOfBirth,
    String? profilePhotoUrl,
    ThemeMode appTheme = ThemeMode.system,
    double generalFontSize = 16.0,
  })  : _firstName = firstName,
        _lastName = lastName,
        _email = email,
        _dateOfBirth = dateOfBirth,
        _profilePhotoUrl = profilePhotoUrl,
        _appTheme = appTheme,
        _generalFontSize = generalFontSize {
    _loadProfile();
  }

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  DateTime? get dateOfBirth => _dateOfBirth;
  String? get profilePhotoUrl => _profilePhotoUrl;
  ThemeMode get appTheme => _appTheme;
  double get generalFontSize => _generalFontSize;

  // Setters and update methods
  void setFirstName(String value) {
    if (_firstName != value) {
      _firstName = value;
      notifyListeners();
      _saveProfile();
    }
  }

  void setLastName(String value) {
    if (_lastName != value) {
      _lastName = value;
      notifyListeners();
      _saveProfile();
    }
  }

  void setEmail(String value) {
    if (_email != value) {
      _email = value;
      notifyListeners();
      _saveProfile();
    }
  }

  void setDateOfBirth(DateTime? value) {
    if (_dateOfBirth != value) {
      _dateOfBirth = value;
      notifyListeners();
      _saveProfile();
    }
  }

  void setProfilePhotoUrl(String? value) {
    if (_profilePhotoUrl != value) {
      _profilePhotoUrl = value;
      notifyListeners();
      _saveProfile();
    }
  }

  void setAppTheme(ThemeMode value) {
    if (_appTheme != value) {
      _appTheme = value;
      notifyListeners();
      _saveProfile();
    }
  }

  void setGeneralFontSize(double value) {
    if (_generalFontSize != value) {
      _generalFontSize = value;
      notifyListeners();
      _saveProfile();
    }
  }

  Future<void> _loadProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _firstName = prefs.getString('profile_firstName') ?? 'Guest';
    _lastName = prefs.getString('profile_lastName') ?? '';
    _email = prefs.getString('profile_email') ?? '';
    final String? dobString = prefs.getString('profile_dateOfBirth');
    _dateOfBirth = dobString != null && dobString.isNotEmpty ? DateTime.parse(dobString) : null;
    _profilePhotoUrl = prefs.getString('profile_photoUrl');
    _appTheme = ThemeMode.values.firstWhere(
          (ThemeMode e) => e.toString() == (prefs.getString('profile_appTheme') ?? ThemeMode.system.toString()),
      orElse: () => ThemeMode.system,
    );
    _generalFontSize = prefs.getDouble('profile_generalFontSize') ?? 16.0;
    notifyListeners();
  }

  Future<void> _saveProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_firstName', _firstName);
    await prefs.setString('profile_lastName', _lastName);
    await prefs.setString('profile_email', _email);
    await prefs.setString('profile_dateOfBirth', _dateOfBirth?.toIso8601String() ?? '');
    await prefs.setString('profile_photoUrl', _profilePhotoUrl ?? '');
    await prefs.setString('profile_appTheme', _appTheme.toString());
    await prefs.setDouble('profile_generalFontSize', _generalFontSize);
  }

  // Method to update all profile fields at once, e.g., after registration/sign-in
  void updateProfileDetails({
    required String firstName,
    required String lastName,
    required String email,
    DateTime? dateOfBirth,
    String? profilePhotoUrl, // Added profilePhotoUrl for initial setup
  }) {
    bool changed = false;
    if (_firstName != firstName) {
      _firstName = firstName;
      changed = true;
    }
    if (_lastName != lastName) {
      _lastName = lastName;
      changed = true;
    }
    if (_email != email) {
      _email = email;
      changed = true;
    }
    if (_dateOfBirth != dateOfBirth) {
      _dateOfBirth = dateOfBirth;
      changed = true;
    }
    if (_profilePhotoUrl != profilePhotoUrl) { // Check for photo change
      _profilePhotoUrl = profilePhotoUrl;
      changed = true;
    }

    if (changed) {
      notifyListeners();
      _saveProfile();
    }
  }
}

// ------------------- PROFILE PAGE -------------------

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  DateTime? _selectedDateOfBirth;

  final List<String> _availableProfilePhotos = <String>[
    'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg',
    'https://images.unsplash.com/photo-1511367461989-f85a21fda167?q=80&w=1931&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29329?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=1976&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  ];

  @override
  void initState() {
    super.initState();
    final ProfileData profileData = context.read<ProfileData>();
    _firstNameController = TextEditingController(text: profileData.firstName);
    _lastNameController = TextEditingController(text: profileData.lastName);
    _emailController = TextEditingController(text: profileData.email);
    _selectedDateOfBirth = profileData.dateOfBirth;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        context.read<ProfileData>().setDateOfBirth(picked);
      });
    }
  }

  void _saveProfileChanges() {
    final ProfileData profileData = context.read<ProfileData>();
    // The controllers update the ProfileData directly via onChanged,
    // so this button just provides confirmation and saves.
    // However, if onChanged was not used, we'd update here.
    // For consistency with other pages, I'll update the values here.
    profileData.setFirstName(_firstNameController.text);
    profileData.setLastName(_lastNameController.text);
    profileData.setEmail(_emailController.text);
    profileData.setDateOfBirth(_selectedDateOfBirth);


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile updated successfully!', style: GoogleFonts.robotoMono()),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text('Profile & Settings',
            style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<ProfileData>(
        builder: (BuildContext context, ProfileData profileData, Widget? child) {
          final TextStyle generalTextStyle = GoogleFonts.robotoMono(fontSize: profileData.generalFontSize);
          final TextStyle labelTextStyle = GoogleFonts.robotoMono(fontSize: profileData.generalFontSize - 2);

          return Padding(
            padding: EdgeInsets.only(top: topPadding, left: 32, right: 32, bottom: 32),
            child: ListView(
              children: <Widget>[
                // Profile Photo Section
                Center(
                  child: Stack(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: profileData.profilePhotoUrl != null && profileData.profilePhotoUrl!.isNotEmpty
                            ? NetworkImage(profileData.profilePhotoUrl!)
                            : null,
                        child: profileData.profilePhotoUrl == null || profileData.profilePhotoUrl!.isEmpty
                            ? Icon(Icons.person, size: 60, color: Colors.grey[700])
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            showDialog<void>(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: Text('Select Profile Picture', style: GoogleFonts.robotoMono()),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                      itemCount: _availableProfilePhotos.length + 1, // +1 for remove option
                                      itemBuilder: (BuildContext _, int index) {
                                        if (index == 0) {
                                          // Option to remove photo
                                          return GestureDetector(
                                            onTap: () {
                                              profileData.setProfilePhotoUrl(null);
                                              Navigator.of(dialogContext).pop();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade100,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.red),
                                              ),
                                              child: const Icon(Icons.cancel, size: 40, color: Colors.red),
                                            ),
                                          );
                                        }
                                        final String url = _availableProfilePhotos[index - 1];
                                        return GestureDetector(
                                          onTap: () {
                                            profileData.setProfilePhotoUrl(url);
                                            Navigator.of(dialogContext).pop();
                                          },
                                          child: Image.network(
                                            url,
                                            fit: BoxFit.cover,
                                            width: 80,
                                            height: 80,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.of(dialogContext).pop(),
                                      child: Text('Cancel', style: GoogleFonts.robotoMono(color: Colors.black)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 20,
                            child: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Profile Editing Section
                Text('Edit Profile Details', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    hintText: 'Enter your first name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    prefixIcon: const Icon(Icons.person),
                    fillColor: Colors.white,
                    filled: true,
                    labelStyle: labelTextStyle,
                  ),
                  style: generalTextStyle,
                  onChanged: (String value) => profileData.setFirstName(value),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    hintText: 'Enter your last name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    prefixIcon: const Icon(Icons.person_outline),
                    fillColor: Colors.white,
                    filled: true,
                    labelStyle: labelTextStyle,
                  ),
                  style: generalTextStyle,
                  onChanged: (String value) => profileData.setLastName(value),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    prefixIcon: const Icon(Icons.email),
                    fillColor: Colors.white,
                    filled: true,
                    labelStyle: labelTextStyle,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: generalTextStyle,
                  onChanged: (String value) => profileData.setEmail(value),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.calendar_today, color: Colors.black54),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          profileData.dateOfBirth == null
                              ? 'Date of Birth (Optional)'
                              : 'Date of Birth: ${DateFormat.yMMMd().format(profileData.dateOfBirth!)}',
                          style: generalTextStyle.copyWith(
                              color: profileData.dateOfBirth == null ? Colors.black54 : Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: _pickDateOfBirth,
                        child: Text(
                          profileData.dateOfBirth == null ? 'Select Date' : 'Change Date',
                          style: GoogleFonts.robotoMono(color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Settings Section
                Text('App Settings', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 20),
                // Theme Mode Setting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('App Theme:', style: generalTextStyle),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: DropdownButton<ThemeMode>(
                        value: profileData.appTheme,
                        onChanged: (ThemeMode? newValue) {
                          if (newValue != null) {
                            profileData.setAppTheme(newValue);
                          }
                        },
                        underline: const SizedBox.shrink(),
                        items: ThemeMode.values.map<DropdownMenuItem<ThemeMode>>((ThemeMode mode) {
                          return DropdownMenuItem<ThemeMode>(
                            value: mode,
                            child: Text(
                              mode.toString().split('.').last.replaceAllMapped(
                                  RegExp(r'([A-Z])'), (Match m) => ' ${m.group(1)}'), // Convert camelCase to space-separated
                              style: generalTextStyle,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // General Font Size Setting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('General Font Size:', style: generalTextStyle),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: () {
                        profileData.setGeneralFontSize((profileData.generalFontSize - 1.0).clamp(12.0, 24.0));
                      },
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        profileData.generalFontSize.toStringAsFixed(0),
                        style: generalTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onPressed: () {
                        profileData.setGeneralFontSize((profileData.generalFontSize + 1.0).clamp(12.0, 24.0));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _saveProfileChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA2D9CE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: GoogleFonts.robotoMono(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

