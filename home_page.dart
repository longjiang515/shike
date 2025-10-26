import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    HomeContentPage(),
    DiscoverPage(),
    FavoritePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.orangeAccent,
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: '首页',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore_rounded),
          label: '发现',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          activeIcon: Icon(Icons.favorite_rounded),
          label: '收藏',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person_rounded),
          label: '我的',
        ),
      ],
    );
  }
}

// 首页内容页面
class HomeContentPage extends StatelessWidget {
  // 根据菜名返回对应的网络图片URL
  String _getRecipeImageUrl(String title) {
    final images = {
      '番茄炒蛋': 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=400&h=300&fit=crop',
      '红烧肉': 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=400&h=300&fit=crop',
      '清炒时蔬': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=300&fit=crop',
      '香煎三文鱼': 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&h=300&fit=crop',
      '麻婆豆腐': 'https://images.unsplash.com/photo-1542528180-a1208c5169a5?w=400&h=300&fit=crop',
      '宫保鸡丁': 'https://images.unsplash.com/photo-1551218808-94e220e084d2?w=400&h=300&fit=crop',
      '春季养生汤': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&h=300&fit=crop',
      '夏日凉拌菜': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=300&fit=crop',
    };
    return images[title] ?? 'https://images.unsplash.com/photo-1551218808-94e220e084d2?w=400&h=300&fit=crop';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 顶部导航栏
        _buildAppBar(),

        // 轮播图
        _buildBannerSlider(),

        // 快捷入口
        _buildQuickActions(),

        // 推荐菜谱
        _buildRecommendedRecipes(),

        // 今日推荐
        _buildTodayRecommendation(),

        // 底部间距
        SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: true,
      snap: true,
      title: Row(
        children: [
          // Logo或应用名称
          Text(
            '食刻',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'ShiKe',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
      actions: [
        // 搜索按钮
        IconButton(
          icon: Icon(Icons.search, color: Colors.grey[700]),
          onPressed: () {
            // 跳转到搜索页面
          },
        ),
        // 通知按钮
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: Colors.grey[700]),
          onPressed: () {
            // 跳转到通知页面
          },
        ),
        // 用户头像
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.orangeAccent.withOpacity(0.2),
            child: Icon(
              Icons.person,
              size: 18,
              color: Colors.orangeAccent,
            ),
          ),
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildBannerSlider() {
    return SliverToBoxAdapter(
      child: Container(
        height: 160,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1551218808-94e220e084d2?w=600&h=300&fit=crop',
            ),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 半透明遮罩
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            // 文字内容 - 使用Padding和约束解决溢出问题
            Padding(
              padding: EdgeInsets.all(16), // 减少内边距
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // 重要：限制Column大小
                children: [
                  Text(
                    '今日特推',
                    style: TextStyle(
                      fontSize: 12, // 减小字体大小
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4), // 减少间距
                  Text(
                    '香煎三文鱼\n配时蔬',
                    style: TextStyle(
                      fontSize: 20, // 减小字体大小
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 8), // 减少间距
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4), // 减小按钮内边距
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '立即学习 →',
                      style: TextStyle(
                        fontSize: 10, // 减小字体大小
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickActionItem(
              icon: Icons.local_grocery_store,
              title: '一键备菜',
              color: Colors.green,
            ),
            _buildQuickActionItem(
              icon: Icons.timer,
              title: '15分钟',
              color: Colors.blue,
            ),
            _buildQuickActionItem(
              icon: Icons.favorite,
              title: '健康',
              color: Colors.red,
            ),
            _buildQuickActionItem(
              icon: Icons.trending_up,
              title: '热门',
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildRecommendedRecipes() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '为你推荐',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    '查看更多',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 推荐菜谱水平列表
            Container(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildRecipeCard(
                    title: '番茄炒蛋',
                    time: '15分钟',
                    difficulty: '简单',
                    rating: 4.8,
                  ),
                  SizedBox(width: 12),
                  _buildRecipeCard(
                    title: '红烧肉',
                    time: '45分钟',
                    difficulty: '中等',
                    rating: 4.9,
                  ),
                  SizedBox(width: 12),
                  _buildRecipeCard(
                    title: '清炒时蔬',
                    time: '10分钟',
                    difficulty: '简单',
                    rating: 4.5,
                  ),
                  SizedBox(width: 12),
                  _buildRecipeCard(
                    title: '麻婆豆腐',
                    time: '20分钟',
                    difficulty: '中等',
                    rating: 4.7,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard({
    required String title,
    required String time,
    required String difficulty,
    required double rating,
  }) {
    return GestureDetector(
      onTap: () {
        // 跳转到菜谱详情页
        print('点击菜谱: $title');
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // 重要：限制Column大小
          children: [
            // 图片区域 - 固定高度
            Container(
              height: 100, // 从120减少到100
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: NetworkImage(_getRecipeImageUrl(title)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // 信息区域 - 使用Expanded或灵活布局
            Padding(
              padding: EdgeInsets.all(10), // 减少内边距
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // 限制内部Column大小
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14, // 减小字体大小
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4), // 减少间距
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 10, color: Colors.grey[500]), // 减小图标
                      SizedBox(width: 2), // 减少间距
                      Text(
                        time,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]), // 减小字体
                      ),
                      Spacer(),
                      Icon(Icons.star, size: 10, color: Colors.orangeAccent), // 减小图标
                      SizedBox(width: 2), // 减少间距
                      Text(
                        rating.toString(),
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]), // 减小字体
                      ),
                    ],
                  ),
                  SizedBox(height: 4), // 减少间距
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1), // 减小内边距
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      difficulty,
                      style: TextStyle(
                        fontSize: 9, // 减小字体大小
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildTodayRecommendation() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '今日时令推荐',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    '更多推荐',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildTodayRecipeItem(
              title: '春季养生汤',
              description: '适合春季养生的营养汤品，滋补又美味',
              calories: '180大卡',
            ),
            SizedBox(height: 12),
            _buildTodayRecipeItem(
              title: '夏日凉拌菜',
              description: '清爽开胃的夏日凉菜，解暑又健康',
              calories: '120大卡',
            ),
            SizedBox(height: 12),
            _buildTodayRecipeItem(
              title: '宫保鸡丁',
              description: '经典川菜，麻辣鲜香，下饭神器',
              calories: '220大卡',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayRecipeItem({
    required String title,
    required String description,
    required String calories,
  }) {
    return GestureDetector(
      onTap: () {
        // 跳转到菜谱详情页
        print('点击今日推荐: $title');
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 图片
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(_getRecipeImageUrl(title)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16),
            // 文字信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department,
                          size: 16, color: Colors.orangeAccent),
                      SizedBox(width: 4),
                      Text(
                        calories,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '学习制作',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 发现页面
class DiscoverPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('发现'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_rounded, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              '发现页面开发中...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 收藏页面
class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的收藏'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_rounded, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              '收藏页面开发中...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 个人中心页面
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('个人中心'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_rounded, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              '个人中心开发中...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}