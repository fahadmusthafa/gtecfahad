import 'package:flutter/material.dart';


class AdminLMSHomePage extends StatefulWidget {
  const AdminLMSHomePage({super.key});

  @override
  State<AdminLMSHomePage> createState() => _AdminLMSHomePageState();
}

class _AdminLMSHomePageState extends State<AdminLMSHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'GO!',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF0098DA),
              size: 28,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF0098DA),
              radius: 18,
              child: IconButton(
                icon: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Panel with ScrollView
              Container(
                width: 280,
                height: double.infinity,
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Courses',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildCourseCard(
                          icon: Icons.desktop_mac,
                          title: 'UI UX Designing Course',
                          isActive: true,
                        ),
                        const SizedBox(height: 16),
                        _buildCourseCard(
                          icon: Icons.campaign,
                          title: 'Digital Marketing Course',
                          isActive: false,
                        ),
                        const SizedBox(height: 32),
                        _buildProgressSection(),
                        const SizedBox(height: 32),
                        _buildProjectSection(),
                        const SizedBox(height: 32),
                        _buildBottomMenu(),
                      ],
                    ),
                  ),
                ),
              ),
              // Main Content with ScrollView
              Expanded(
                child: Container(
                  height: double.infinity,
                  color: const Color(0xFFFAFAFA),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live Sessions',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Join your live session by click the below area!',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildLiveSessionCard(),
                        const SizedBox(height: 32),
                        _buildTabsSection(),
                        const SizedBox(height: 32),
                        _buildVideoLessonsSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard({
    required IconData icon,
    required String title,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE3F2FF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF0098DA) : const Color(0xFF666666),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? const Color(0xFF0098DA) : const Color(0xFF666666),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Course Progress',
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: const LinearProgressIndicator(
            value: 0.10,
            backgroundColor: Color(0xFFEEEEEE),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A1B41)),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '10%',
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Completed',
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 15,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '3/21',
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomMenu() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.person_outline,
          title: 'Contact Program Manager',
        ),
        const SizedBox(height: 16),
        _buildMenuItem(
          icon: Icons.pause_circle_outline,
          title: 'Raise a Pause Request',
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF666666),
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveSessionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8EE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.play_circle_fill,
                  color: Color(0xFFFF4081),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Color(0xFFFF4081),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Module 6 - Design system creating',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Zoom Meeting',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0098DA),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Join Live Class',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsSection() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Row(
        children: [
          Column(
            children: [
              const Text(
                'Course Content',
                style: TextStyle(
                  color: Color(0xFF0098DA),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 2,
                width: 120,
                color: const Color(0xFF0098DA),
              ),
            ],
          ),
          const SizedBox(width: 32),
          const Text(
            'Priority Task',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoLessonsSection() {
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Videos Lessons',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'You will unlock everything you need to become a pro!',
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 24),
        _buildModuleCard(
          title: 'Module 1 - Ice breaking',
          progress: '2/3',
          videosCount: '3 Recorded Videos',
          progressColor: Colors.amber,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('- Video 1: Introduction'),
              Text('- Video 2: Warm-up exercise'),
              Text('- Video 3: Ice breaking activity'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildModuleCard(
          title: 'Module 2 - Advanced techniques',
          progress: '4/4',
          videosCount: '4 Recorded Videos',
          progressColor: Colors.green,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('- Video 1: Overview of techniques'),
              Text('- Video 2: Case studies'),
              Text('- Video 3: Application examples'),
              Text('- Video 4: Wrap-up'),
            ],
          ),
        ),
      ],
    );
  }

  final Map<String, bool> _expandedState = {};

  Widget _buildModuleCard({
    required String title,
    required String progress,
    required String videosCount,
    required Color progressColor,
    required Widget content,
  }) {
    final progressValue = int.parse(progress.split('/')[0]) /
        int.parse(progress.split('/')[1]);
    final isExpanded = _expandedState[title] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedState[title] = !isExpanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: progressValue,
                        backgroundColor: const Color(0xFFEEEEEE),
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        strokeWidth: 4,
                      ),
                      Center(
                        child: Text(
                          progress,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        videosCount,
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF666666),
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 16),
              content,
            ],
          ],
        ),
      ),
    );
  }
}



class ModuleDropdown extends StatefulWidget {
  const ModuleDropdown({super.key});

  @override
  State<ModuleDropdown> createState() => _ModuleDropdownState();
}

class _ModuleDropdownState extends State<ModuleDropdown> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Progress Circle
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green,
                        width: 3,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "4/4",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Module 2 - Ice breaking",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.video_library_outlined,
                              size: 16,
                              color: Color(0xFF666666),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "4 Recorded Videos",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Dropdown arrow
                  IconButton(
                    icon: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF666666),
                    ),
                    onPressed: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 16),
                _buildExpandedContent(),
                _buildExpandedContent(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          // Checkmark circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Module 2 - Ice breaking",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.video_library_outlined,
                      size: 16,
                      color: Color(0xFF666666),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "4 Recorded Videos",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // View Recording button
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0098DA),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "View Recording",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}