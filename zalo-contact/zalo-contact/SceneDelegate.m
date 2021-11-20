//
//  SceneDelegate.m
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import "SceneDelegate.h"
#import "ViewControllers/ContactViewController.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate
@synthesize window;

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    window = [[UIWindow alloc] initWithWindowScene: windowScene];
    window.backgroundColor = UIColor.blackColor;

    NSMutableArray *tabItems = [[NSMutableArray alloc] init];
    
    //MARK: - Home
    UINavigationController * homeNav = [[UINavigationController alloc] init];
    homeNav.tabBarItem.title = @"Home";
    homeNav.tabBarItem.image = [UIImage imageNamed:@"tb_home"];
    [homeNav pushViewController: UIViewController.alloc.init animated:NO];

    [tabItems addObject: homeNav];
    
    
    //MARK: - Contact
    UINavigationController * contactNav = [[UINavigationController alloc] init];
    contactNav.tabBarItem.title = @"Contact";
    contactNav.tabBarItem.image = [UIImage imageNamed:@"tb_contact"];
    [contactNav pushViewController: ContactViewController.alloc.init animated:NO];

    [tabItems addObject: contactNav];
    
    //MARK: - Contact
    UINavigationController * userNav = [[UINavigationController alloc] init];
    userNav.tabBarItem.title = @"User";
    userNav.tabBarItem.image = [UIImage imageNamed:@"tb_user"];
    [userNav pushViewController: UIViewController.alloc.init animated:NO];

    [tabItems addObject: userNav];
                                
    UITabBarController *tabbar = [[UITabBarController alloc] init];
         
    [tabbar setViewControllers:tabItems animated:YES];
    
    self.tabbarController = tabbar;
    self.tabbarController.selectedIndex = 1;
        
    
    [self.window setRootViewController:self.tabbarController];
       [self.window makeKeyAndVisible];
    
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}


@end
