import 'package:flutter/material.dart';
import 'SubjectDetailScreen.dart';

class SubjectCategoryScreen extends StatelessWidget {
  final String category;
  final String userName;
  final String userRole;
  final String profileImageUrl;
  final String idUser;

  const SubjectCategoryScreen({
    Key? key,
    required this.category,
    required this.userName,
    required this.userRole,
    required this.profileImageUrl,
    required this.idUser, required String recipientImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> subjects = _getSubjectsByCategory(category);

    return Scaffold(
      appBar: AppBar(
        title: Text('$category Subjects'),
        backgroundColor: const Color.fromARGB(255, 28, 195, 198),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: subjects.isNotEmpty
          ? GridView.builder(
              padding: EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 3 / 2,
              ),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubjectDetailScreen(
                          subject: subject,
                          userName: userName,
                          userRole: userRole,
                          profileImageUrl: profileImageUrl,
                          userId: idUser,
                          tutorId: '',
                          idUser: idUser,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.blue[50],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(subject['icon'], size: 40, color: Colors.blue),
                          SizedBox(height: 10),
                          Text(
                            subject['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text(
                'No subjects available in this category',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
    );
  }

  List<Map<String, dynamic>> _getSubjectsByCategory(String category) {
    switch (category) {
      case 'Language':
        return [
          {
            'name': 'Thai',
            'icon': Icons.language,
            'description': 'เรียนรู้ภาษาไทยทั้งการพูดและการเขียน'
          },
          {
            'name': 'English',
            'icon': Icons.language,
            'description': 'ฝึกทักษะภาษาอังกฤษในทุกด้าน'
          },
          {
            'name': 'Chinese',
            'icon': Icons.language,
            'description': 'เรียนรู้ภาษาจีนเพื่อการสื่อสาร'
          },
          {
            'name': 'French',
            'icon': Icons.language,
            'description': 'ศึกษาภาษาฝรั่งเศสเพื่อการท่องเที่ยวและธุรกิจ'
          },
          {
            'name': 'German',
            'icon': Icons.language,
            'description': 'เข้าใจภาษาเยอรมันในชีวิตประจำวัน'
          },
          {
            'name': 'Japanese',
            'icon': Icons.language,
            'description': 'เรียนรู้ภาษาญี่ปุ่นพร้อมกับวัฒนธรรม'
          },
          {
            'name': 'Korean',
            'icon': Icons.language,
            'description': 'ฝึกทักษะการพูดและฟังภาษาเกาหลี'
          },
          {
            'name': 'Spanish',
            'icon': Icons.language,
            'description': 'เข้าใจภาษาสเปนสำหรับการเดินทางและธุรกิจ'
          },
          {
            'name': 'Arabic',
            'icon': Icons.language,
            'description': 'เรียนรู้ภาษาอาหรับเพื่อการสื่อสาร'
          },
          {
            'name': 'Russian',
            'icon': Icons.language,
            'description': 'ฝึกทักษะภาษารัสเซียสำหรับการทำงาน'
          },
          {
            'name': 'Italian',
            'icon': Icons.language,
            'description': 'ฝึกทักษะภาษาอิตาลีเพื่อการท่องเที่ยว'
          },
          {
            'name': 'Portuguese',
            'icon': Icons.language,
            'description': 'เรียนรู้ภาษาโปรตุเกสเพื่อธุรกิจและการสื่อสาร'
          },
        ];
      case 'Mathematics':
        return [
          {
            'name': 'Algebra',
            'icon': Icons.calculate,
            'description': 'เข้าใจพื้นฐานของพีชคณิตและการประยุกต์ใช้'
          },
          {
            'name': 'Geometry',
            'icon': Icons.square_foot,
            'description': 'เรียนรู้เรขาคณิตและการแก้ปัญหา'
          },
          {
            'name': 'Calculus',
            'icon': Icons.functions,
            'description': 'ศึกษาการคิดคำนวณแคลคูลัส'
          },
          {
            'name': 'Statistics',
            'icon': Icons.bar_chart,
            'description': 'ฝึกทักษะในการวิเคราะห์สถิติ'
          },
          {
            'name': 'Trigonometry',
            'icon': Icons.timeline,
            'description': 'เข้าใจพื้นฐานของตรีโกณมิติ'
          },
          {
            'name': 'Linear Algebra',
            'icon': Icons.linear_scale,
            'description': 'เรียนรู้การแก้ปัญหาด้วยพีชคณิตเชิงเส้น'
          },
          {
            'name': 'Differential Equations',
            'icon': Icons.graphic_eq,
            'description': 'ศึกษาและประยุกต์ใช้สมการเชิงอนุพันธ์'
          },
          {
            'name': 'Discrete Mathematics',
            'icon': Icons.grain,
            'description': 'ฝึกทักษะการแก้ปัญหาด้วยคณิตศาสตร์เชิงไม่ต่อเนื่อง'
          },
          {
            'name': 'Number Theory',
            'icon': Icons.format_list_numbered,
            'description': 'ศึกษาและสำรวจทฤษฎีจำนวน'
          },
          {
            'name': 'Mathematical Logic',
            'icon': Icons.category,
            'description': 'เข้าใจพื้นฐานของตรรกศาสตร์คณิตศาสตร์'
          },
          {
            'name': 'Complex Analysis',
            'icon': Icons.analytics,
            'description': 'ศึกษาการวิเคราะห์เชิงซ้อน'
          },
          {
            'name': 'Operations Research',
            'icon': Icons.manage_search,
            'description': 'เรียนรู้การวิเคราะห์และปรับปรุงกระบวนการ'
          },
        ];
      case 'Science':
        return [
          {
            'name': 'Physics',
            'icon': Icons.science,
            'description': 'ศึกษาและเข้าใจกฎฟิสิกส์และการประยุกต์'
          },
          {
            'name': 'Chemistry',
            'icon': Icons.biotech,
            'description': 'เรียนรู้เกี่ยวกับเคมีและปฏิกิริยาเคมี'
          },
          {
            'name': 'Biology',
            'icon': Icons.eco,
            'description': 'ศึกษาและเข้าใจชีวิตและสิ่งแวดล้อม'
          },
          {
            'name': 'Environmental Science',
            'icon': Icons.nature_people,
            'description': 'ศึกษาเกี่ยวกับสิ่งแวดล้อมและการอนุรักษ์'
          },
          {
            'name': 'Earth Science',
            'icon': Icons.terrain,
            'description': 'เข้าใจพื้นฐานของธรณีวิทยาและธรณีภาค'
          },
          {
            'name': 'Astronomy',
            'icon': Icons.star,
            'description': 'สำรวจและศึกษาเรื่องจักรวาลและดาราศาสตร์'
          },
          {
            'name': 'Zoology',
            'icon': Icons.pets,
            'description': 'ศึกษาเกี่ยวกับสัตววิทยาและสัตว์ต่าง ๆ'
          },
          {
            'name': 'Botany',
            'icon': Icons.local_florist,
            'description': 'เรียนรู้เกี่ยวกับพฤกษศาสตร์และพืชพรรณ'
          },
          {
            'name': 'Microbiology',
            'icon': Icons.science,
            'description': 'ศึกษาเกี่ยวกับจุลชีววิทยาและแบคทีเรียmicroscop'
          },
          {
            'name': 'Genetics',
            'icon': Icons.science,
            'description': 'สำรวจพื้นฐานของพันธุศาสตร์และการถ่ายทอด'
          },
          {
            'name': 'Ecology',
            'icon': Icons.eco,
            'description': 'ศึกษาเกี่ยวกับระบบนิเวศและสิ่งแวดล้อม'
          },
          {
            'name': 'Marine Biology',
            'icon': Icons.pool,
            'description': 'เรียนรู้เกี่ยวกับชีววิทยาทางทะเล'
          },
        ];
      case 'Computer Science':
        return [
          {
            'name': 'Programming',
            'icon': Icons.computer,
            'description': 'ฝึกทักษะการเขียนโปรแกรมในภาษาต่าง ๆ'
          },
          {
            'name': 'Data Structures',
            'icon': Icons.storage,
            'description': 'เข้าใจและออกแบบโครงสร้างข้อมูล'
          },
          {
            'name': 'Networking',
            'icon': Icons.network_wifi,
            'description': 'เรียนรู้เกี่ยวกับการสื่อสารและเครือข่าย'
          },
          {
            'name': 'Algorithms',
            'icon': Icons.code,
            'description': 'ศึกษาการออกแบบและวิเคราะห์อัลกอริธึม'
          },
          {
            'name': 'Operating Systems',
            'icon': Icons.memory,
            'description': 'ศึกษาและเข้าใจการทำงานของระบบปฏิบัติการ'
          },
          {
            'name': 'Databases',
            'icon': Icons.storage,
            'description': 'ฝึกทักษะในการออกแบบและจัดการฐานข้อมูล'
          },
          {
            'name': 'Artificial Intelligence',
            'icon': Icons.smart_toy,
            'description': 'เข้าใจพื้นฐานของปัญญาประดิษฐ์'
          },
          {
            'name': 'Cybersecurity',
            'icon': Icons.security,
            'description': 'เรียนรู้เกี่ยวกับการรักษาความปลอดภัยไซเบอร์'
          },
          {
            'name': 'Software Engineering',
            'icon': Icons.engineering,
            'description': 'ศึกษาและพัฒนาโครงสร้างซอฟต์แวร์'
          },
          {
            'name': 'Web Development',
            'icon': Icons.web,
            'description': 'ฝึกทักษะในการพัฒนาเว็บและแอปพลิเคชัน'
          },
          {
            'name': 'Mobile Development',
            'icon': Icons.phone_android,
            'description': 'เรียนรู้การพัฒนาแอปพลิเคชันบนมือถือ'
          },
          {
            'name': 'Cloud Computing',
            'icon': Icons.cloud,
            'description': 'ศึกษาเกี่ยวกับการประมวลผลบนคลาวด์'
          },
        ];
      case 'Business':
        return [
          {
            'name': 'Economics',
            'icon': Icons.business,
            'description': 'เรียนรู้เกี่ยวกับเศรษฐศาสตร์และตลาด'
          },
          {
            'name': 'Finance',
            'icon': Icons.account_balance,
            'description': 'ศึกษาและฝึกทักษะในการบริหารการเงิน'
          },
          {
            'name': 'Marketing',
            'icon': Icons.campaign,
            'description': 'เข้าใจการตลาดและการโฆษณา'
          },
          {
            'name': 'Management',
            'icon': Icons.manage_accounts,
            'description': 'ฝึกทักษะในการบริหารจัดการองค์กร'
          },
          {
            'name': 'Accounting',
            'icon': Icons.receipt_long,
            'description': 'ศึกษาและฝึกทักษะการบัญชีและการเงิน'
          },
          {
            'name': 'Entrepreneurship',
            'icon': Icons.lightbulb,
            'description': 'เรียนรู้การสร้างธุรกิจและนวัตกรรม'
          },
          {
            'name': 'Human Resources',
            'icon': Icons.people,
            'description': 'ศึกษาเกี่ยวกับทรัพยากรมนุษย์และการจัดการ'
          },
          {
            'name': 'Business Law',
            'icon': Icons.gavel,
            'description': 'เข้าใจเกี่ยวกับกฎหมายธุรกิจ'
          },
          {
            'name': 'Operations Management',
            'icon': Icons.precision_manufacturing,
            'description': 'ฝึกทักษะการจัดการการผลิตและการดำเนินงาน'
          },
          {
            'name': 'Business Ethics',
            'icon': Icons.business_center,
            'description': 'ศึกษาเกี่ยวกับจริยธรรมทางธุรกิจ'
          },
          {
            'name': 'International Business',
            'icon': Icons.public,
            'description': 'เรียนรู้การทำธุรกิจในระดับสากล'
          },
        ];
      case 'Arts':
        return [
          {
            'name': 'Drawing',
            'icon': Icons.brush,
            'description': 'ฝึกทักษะการวาดภาพและสเก็ตช์'
          },
          {
            'name': 'Painting',
            'icon': Icons.color_lens,
            'description': 'ศึกษาและพัฒนาการวาดภาพและระบายสี'
          },
          {
            'name': 'Music',
            'icon': Icons.music_note,
            'description': 'ฝึกทักษะในการเล่นดนตรีและแต่งเพลง'
          },
          {
            'name': 'Dance',
            'icon': Icons.accessibility_new,
            'description': 'เรียนรู้การเต้นและการแสดง'
          },
          {
            'name': 'Drama',
            'icon': Icons.theater_comedy,
            'description': 'ฝึกทักษะในการแสดงละครและการพูด'
          },
          {
            'name': 'Sculpture',
            'icon': Icons.emoji_objects,
            'description': 'ฝึกทักษะการสร้างประติมากรรม'
          },
          {
            'name': 'Photography',
            'icon': Icons.camera_alt,
            'description': 'ฝึกทักษะการถ่ายภาพและการตกแต่งภาพ'
          },
          {
            'name': 'Graphic Design',
            'icon': Icons.design_services,
            'description': 'ศึกษาและพัฒนาในงานออกแบบกราฟิก'
          },
          {
            'name': 'Film Studies',
            'icon': Icons.movie,
            'description': 'เรียนรู้เกี่ยวกับการผลิตภาพยนตร์และการตัดต่อ'
          },
          {
            'name': 'Fashion Design',
            'icon': Icons.checkroom,
            'description': 'ฝึกทักษะการออกแบบและผลิตเสื้อผ้า'
          },
          {
            'name': 'Interior Design',
            'icon': Icons.home,
            'description': 'ฝึกทักษะการออกแบบและตกแต่งภายใน'
          },
          {
            'name': 'Architecture',
            'icon': Icons.architecture,
            'description': 'ศึกษาเกี่ยวกับสถาปัตยกรรมและการออกแบบ'
          },
        ];
      case 'Physical Education':
        return [
          {
            'name': 'Sports',
            'icon': Icons.sports_basketball,
            'description': 'ฝึกทักษะการเล่นกีฬาต่าง ๆ'
          },
          {
            'name': 'Health',
            'icon': Icons.health_and_safety,
            'description': 'ศึกษาเกี่ยวกับสุขภาพและการดูแลตนเอง'
          },
          {
            'name': 'Fitness',
            'icon': Icons.fitness_center,
            'description': 'ฝึกทักษะการออกกำลังกายและการสร้างกล้ามเนื้อ'
          },
          {
            'name': 'Yoga',
            'icon': Icons.self_improvement,
            'description': 'ฝึกทักษะการทำโยคะและการผ่อนคลาย'
          },
          {
            'name': 'Martial Arts',
            'icon': Icons.sports_mma,
            'description': 'ศึกษาและฝึกศิลปะการต่อสู้'
          },
          {
            'name': 'Swimming',
            'icon': Icons.pool,
            'description': 'ฝึกทักษะการว่ายน้ำและการช่วยเหลือในน้ำ'
          },
          {
            'name': 'Gymnastics',
            'icon': Icons.sports_gymnastics,
            'description': 'ฝึกทักษะการทำยิมนาสติก'
          },
          {
            'name': 'Track and Field',
            'icon': Icons.sports,
            'description': 'ฝึกทักษะการวิ่งและการแข่งขัน'
          },
          {
            'name': 'Cycling',
            'icon': Icons.pedal_bike,
            'description': 'ฝึกทักษะการขี่จักรยาน'
          },
          {
            'name': 'Boxing',
            'icon': Icons.sports_kabaddi,
            'description': 'ฝึกทักษะการชกมวย'
          },
          {
            'name': 'Athletics',
            'icon': Icons.sports_handball,
            'description': 'ฝึกทักษะกีฬาในสนามและการแข่งกรีฑา'
          },
          {
            'name': 'Nutrition',
            'icon': Icons.restaurant,
            'description': 'ศึกษาเกี่ยวกับโภชนาการและอาหารเพื่อสุขภาพ'
          },
        ];
      default:
        return [];
    }
  }
}
