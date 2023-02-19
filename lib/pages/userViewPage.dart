


import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../model/member_model.dart';
import '../model/post_model.dart';
import '../service/db_service.dart';

class userViewPage extends StatefulWidget {
  final Member? member;
  final int? postsCount;
  const userViewPage({Key? key, this.member, this.postsCount,}) : super(key: key);

  @override
  State<userViewPage> createState() => _userViewPageState();
}

class _userViewPageState extends State<userViewPage> {
  List<Post> items = [];

  String fullName = "";
  String email = "";
  String imgUrl = "";
  int countPosts = 0, countFollowers = 0, countFollowing = 0;
  bool isLoading = false;

  void loadPosts() async {
    List<Post> posts = await DataService.loadsomeonePosts(widget.member!.uid);
    setState(() {
      items = posts;
      countPosts = items.length;
      isLoading = false;
    });
  }

  void followMember(Member member) async {
    setState(() {
      member.followed = true;
      countFollowers++;
    });
    await DataService.followMember(member);
  }

  void unFollowMember(Member member) async {
    setState(() {
      member.followed = false;
      countFollowers--;
    });
    await DataService.unfollowMember(member);
  }

  void getMember() {
    setState(() {
      isLoading = true;
    });
    DataService.loadsomeoneMember(widget.member!.uid).then((member) => {
      setState((){
        fullName = member.fullName!;
        email = member.email!;
        imgUrl = member.img_url;
        countFollowers = member.followers_count;
        countFollowing = member.following_count;
        loadPosts();
      }),
    });
  }

  @override
  void initState() {
    getMember();
    loadPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
           appBar: AppBar(
             backgroundColor: Colors.white,
             iconTheme: IconThemeData(
               color: Colors.black
             ),
             elevation: 0,
           ),
          body: Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(70),
                        border: Border.all(
                          width: 1.5,
                          color: Color.fromRGBO(193, 53, 132, 1),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: (imgUrl.isNotEmpty) ?
                        Image.network(imgUrl, height: 70, width: 70, fit: BoxFit.cover,) :
                        Image(
                          height: 70,
                          width: 70,
                          image: AssetImage("assets/images/ic_userImage.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  ],
                ),
                SizedBox(height: 10,),
                Text(fullName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                Text(email, style: TextStyle(color: Colors.black54),),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child:widget.member!.followed ?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 30,
                            child: OutlinedButton(
                              onPressed: (){
                                setState(() {
                                  widget.member!.followed = false;
                                  unFollowMember(widget.member!);
                                });
                              },
                              child: Text("Followed"),
                            ),
                          ),
                        ],
                      ) :
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 30,
                            child: MaterialButton(
                              onPressed: (){
                                setState(() {
                                  widget.member!.followed = true;
                                  followMember(widget.member!);
                                });
                              },
                              child: Text("Follow", style: TextStyle(color: Colors.white)),
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ) ,
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  height: 80,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(countPosts.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                            Text("POSTS", style: TextStyle(color: Colors.grey),),
                          ],
                        ),
                      ),
                      VerticalDivider(indent: 20, endIndent: 20, color: Colors.grey),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(countFollowers.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                            Text("FOLLOWERS", style: TextStyle(color: Colors.grey),),
                          ],
                        ),
                      ),
                      VerticalDivider(indent: 20, endIndent: 20, color: Colors.grey),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(countFollowing.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                            Text("FOLLOWING", style: TextStyle(color: Colors.grey),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _itemOfPost(items[index]);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        (isLoading) ?
        Scaffold(
          backgroundColor: Colors.grey.withOpacity(.3),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ) : SizedBox(),
      ],
    );
  }


  Widget _itemOfPost(Post post) {
    return Container(
      margin: EdgeInsets.all(5),
      child: Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              width: double.infinity,
              imageUrl: post.imgPost!,
              placeholder: (context, url) {
                return Center(child: CircularProgressIndicator(),);
              },
              errorWidget: (context, url, error) {
                return Icon(Icons.error);
              },
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 3,),
          Text(post.caption!)
        ],
      ),
    );
  }
}
