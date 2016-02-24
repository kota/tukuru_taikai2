//
//  ViewController.swift
//  Taikai2
//
//  Created by fujiwara.kota on 2016/02/24.
//  Copyright © 2016年 Moneyforward. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let ButtonWidth = CGFloat(18)
    let N = 100
    let M = 5
    
    var board = [[Turn?]]()
    var buttons = [UIButton]()
    @IBOutlet weak var logLabel: UILabel!
    
    enum Turn {
        case Black
        case White
        
        func name() -> String {
            switch self {
            case .Black:
                return "黒"
            case .White:
                return "白"
            }
        }
    }
    
    var turn: Turn = .Black
    
    @IBOutlet weak var rootView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setup() {
        for var i=0; i<N; i++ {
            var column = [Turn?]()
            for var j=0; j<N; j++ {
                column.append(nil)
                
                let frame = CGRectMake(CGFloat(i) * ButtonWidth, CGFloat(j) * ButtonWidth, ButtonWidth, ButtonWidth)
                let button = CellButton(frame: frame)
                button.x = i
                button.y = j
                button.backgroundColor = UIColor.grayColor()
                button.layer.borderColor = UIColor.blackColor().CGColor
                button.layer.borderWidth = 1.0
                button.addTarget(self, action: Selector("cellTapped:"), forControlEvents: .TouchUpInside)
                
                self.rootView.addSubview(button)
                buttons.append(button)
            }
            board.append(column)
        }
        logLabel.text = "\(self.turn.name())の手番です"
    }
    
    func reset() {
        for var button in self.buttons {
            button.backgroundColor = UIColor.grayColor()
        }
        for var i=0; i<N; i++ {
            for var j=0; j<N; j++ {
                board[i][j] = nil
            }
        }
    }
    
    func cellTapped(sender: UIButton) {
        guard let cell = sender as? CellButton else {
            return
        }
        
        logLabel.text = ""
        
        if !isValid(cell.x, y: cell.y) {
            logLabel.text = "そこには置けません"
            return
        }
        
        board[cell.x][cell.y] = self.turn
        
        switch self.turn {
        case .Black:
            cell.backgroundColor = UIColor.blackColor()
        case .White:
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        if isGameFinished(cell.x, y: cell.y) {
            logLabel.text = "\(self.turn.name())の勝ちです"
            self.reset()
            return
        }
        
        self.turn = self.turn == .Black ? .White : .Black
        logLabel.text = "\(self.turn.name())の手番です"
    }
    
    func isValid(x:Int,y:Int) -> Bool {
        return board[x][y] == nil
    }
    
    func isGameFinished(x:Int,y:Int) -> Bool {
        let vertical = findSuccessiveStones(self.turn, x: x, y: y, dx: 0, dy: -1, count: 0) +
                       findSuccessiveStones(self.turn, x: x, y: y, dx: 0, dy: 1, count: 0) + 1
        
        let horizontal = findSuccessiveStones(self.turn, x: x, y: y, dx: -1, dy: 0, count: 0) +
                         findSuccessiveStones(self.turn, x: x, y: y, dx: 1, dy: 0, count: 0) + 1
        
        let diagonal1 = findSuccessiveStones(self.turn, x: x, y: y, dx: -1, dy: -1, count: 0) +
                        findSuccessiveStones(self.turn, x: x, y: y, dx: 1, dy: 1, count: 0) + 1
        
        let diagonal2 = findSuccessiveStones(self.turn, x: x, y: y, dx: 1, dy: -1, count: 0) +
                        findSuccessiveStones(self.turn, x: x, y: y, dx: -1, dy: 1, count: 0) + 1
        
        return vertical >= M || horizontal >= M || diagonal1 >= M || diagonal2 >= M
    }
    
    func findSuccessiveStones(color: Turn, x:Int, y:Int, dx:Int, dy:Int, count:Int) -> Int {
        let newX = x + dx
        let newY = y + dy
        if newX > N-1 || newX < 0 || newY > N-1 || newY < 0 {
            return count
        }
        
        if board[newX][newY] == color {
            if count + 1 >= M {
                return count + 1
            } else {
                return findSuccessiveStones(color, x: newX, y: newY, dx: dx, dy: dy, count: count + 1)
            }
        } else {
            return count
        }
    }
}

